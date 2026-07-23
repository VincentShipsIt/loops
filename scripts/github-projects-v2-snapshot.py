#!/usr/bin/env python3
"""Take a safe, bounded GitHub Projects v2 REST snapshot.

This helper is deliberately read-only. It validates exact project identity and
required field projections before returning item/status data. A missing field
in one response is reported as an incomplete projection; it is never treated
as permission to create or rename a project field.

Targets are supplied as JSON so this template stays project-agnostic. Example:

    [
      {
        "owner": "[OWNER]",
        "owner_type": "org",
        "project_number": 1,
        "project_title": "[PROJECT]",
        "repository": "[OWNER]/[REPO]",
        "required_fields": ["Status", "Priority", "Milestone"]
      }
    ]
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import shutil
import subprocess
import sys
import time
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any


API_VERSION = "2026-03-10"
DEFAULT_GH = "/opt/homebrew/bin/gh"
DEFAULT_AGENT_HEAD_PREFIXES = ("agent/", "claude/", "codex/")
DEFAULT_MAX_WORKERS = 8
GH_TIMEOUT_SECONDS = 30


class SnapshotError(RuntimeError):
    """A bounded snapshot failed or was incomplete."""

    def __init__(self, kind: str, message: str, **details: Any) -> None:
        super().__init__(message)
        self.kind = kind
        self.details = details


def gh_path() -> str:
    return shutil.which("gh") or DEFAULT_GH


def gh_json(
    endpoint: str,
    *,
    paginate: bool = False,
    attempts: int = 1,
) -> Any:
    command = [
        gh_path(),
        "api",
        "-H",
        "Accept: application/vnd.github+json",
        "-H",
        f"X-GitHub-Api-Version: {API_VERSION}",
    ]
    if paginate:
        command.extend(["--paginate", "--slurp"])
    command.append(endpoint)
    last_error: SnapshotError | None = None
    for attempt in range(attempts):
        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                check=False,
                timeout=GH_TIMEOUT_SECONDS,
            )
        except subprocess.TimeoutExpired:
            last_error = SnapshotError(
                "transport_timeout",
                f"GitHub REST request timed out for {endpoint}",
                endpoint=endpoint,
            )
        except OSError as exc:
            last_error = SnapshotError(
                "transport_failure",
                f"Unable to execute gh: {exc}",
                endpoint=endpoint,
            )
        else:
            if result.returncode != 0:
                last_error = SnapshotError(
                    "api_failure",
                    f"GitHub REST request failed for {endpoint}",
                    endpoint=endpoint,
                    detail=result.stderr.strip()[:500],
                )
            else:
                try:
                    return json.loads(result.stdout)
                except json.JSONDecodeError:
                    last_error = SnapshotError(
                        "invalid_response",
                        f"GitHub REST response was not JSON for {endpoint}",
                        endpoint=endpoint,
                    )
        if attempt + 1 < attempts:
            time.sleep(0.25 * (attempt + 1))
    assert last_error is not None
    raise last_error


def flatten_pages(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, list):
        raise SnapshotError("invalid_response", "Paginated REST response was not an array")
    if not payload:
        return []
    if not all(isinstance(page, list) for page in payload):
        raise SnapshotError("invalid_response", "Paginated REST response had an unexpected shape")
    return [item for page in payload for item in page if isinstance(item, dict)]


def owner_prefix(target: dict[str, Any]) -> str:
    owner_type = target.get("owner_type")
    if owner_type not in {"org", "user"}:
        raise SnapshotError("invalid_target", "owner_type must be org or user")
    owner = target.get("owner")
    if not isinstance(owner, str) or not owner:
        raise SnapshotError("invalid_target", "owner is required")
    return f"{owner_type}s/{owner}"


def project_prefix(target: dict[str, Any]) -> str:
    number = target.get("project_number")
    if not isinstance(number, int) or number < 1:
        raise SnapshotError("invalid_target", "project_number must be a positive integer")
    return f"{owner_prefix(target)}/projectsV2/{number}"


def value_name(value: Any) -> str | None:
    if isinstance(value, dict):
        name = value.get("name")
        if isinstance(name, dict):
            return name.get("raw") or name.get("html")
        if isinstance(name, str):
            return name
    return value if isinstance(value, str) else None


def field_value(item: dict[str, Any], field_name: str) -> Any:
    for field in item.get("fields") or []:
        if field.get("name") == field_name:
            return field.get("value")
    return None


def resolve_required_fields(
    target: dict[str, Any], fields: list[dict[str, Any]]
) -> tuple[dict[str, int], dict[str, str], list[dict[str, Any]]]:
    by_name: dict[str, list[dict[str, Any]]] = {}
    for field in fields:
        name = field.get("name")
        if isinstance(name, str):
            by_name.setdefault(name, []).append(field)

    required = target.get("required_fields")
    if not isinstance(required, list) or not all(isinstance(name, str) for name in required):
        raise SnapshotError("invalid_target", "required_fields must be a list of strings")
    fallbacks = target.get("field_fallbacks") or {}
    if not isinstance(fallbacks, dict):
        raise SnapshotError("invalid_target", "field_fallbacks must be an object")

    field_ids: dict[str, int] = {}
    resolved_names: dict[str, str] = {}
    problems: list[dict[str, Any]] = []
    for required_name in required:
        candidates = by_name.get(required_name, [])
        resolved_name = required_name
        if not candidates and isinstance(fallbacks.get(required_name), str):
            resolved_name = fallbacks[required_name]
            candidates = by_name.get(resolved_name, [])
        if len(candidates) != 1:
            problems.append(
                {
                    "field": required_name,
                    "resolved_name": resolved_name,
                    "reason": "missing" if not candidates else "duplicate",
                    "count": len(candidates),
                }
            )
            continue
        field_id = candidates[0].get("id")
        if not isinstance(field_id, int):
            problems.append({"field": required_name, "reason": "non_numeric_id"})
            continue
        field_ids[required_name] = field_id
        resolved_names[required_name] = resolved_name

    if problems:
        raise SnapshotError(
            "field_projection_incomplete",
            "Required project fields were missing or duplicated in this response; no schema mutation is allowed.",
            problems=problems,
        )
    return field_ids, resolved_names, []


def snapshot_target(target: dict[str, Any]) -> dict[str, Any]:
    prefix = project_prefix(target)
    project = gh_json(prefix)
    expected_title = target.get("project_title")
    if project.get("title") != expected_title or project.get("state") != "open":
        raise SnapshotError(
            "identity_mismatch",
            "Resolved project did not match the exact requested open project.",
            expected_title=expected_title,
            actual_title=project.get("title"),
            state=project.get("state"),
        )

    fields = flatten_pages(gh_json(f"{prefix}/fields?per_page=100", paginate=True))
    field_ids, resolved_names, _ = resolve_required_fields(target, fields)
    requested_ids = ",".join(str(field_ids[name]) for name in field_ids)
    pages = gh_json(f"{prefix}/items?per_page=100&fields={requested_ids}", paginate=True)
    items = flatten_pages(pages)
    repository = target.get("repository")
    exact_open_items = [
        item
        for item in items
        if (item.get("content") or {}).get("repository", {}).get("full_name") == repository
        and (item.get("content") or {}).get("state") == "open"
    ]

    status_field = resolved_names.get("Status")
    status_counts: Counter[str] = Counter()
    missing_item_fields = Counter[str]()
    for item in exact_open_items:
        if status_field:
            status = value_name(field_value(item, status_field)) or "MISSING"
            status_counts[status] += 1
        for required_name, resolved_name in resolved_names.items():
            if field_value(item, resolved_name) is None:
                missing_item_fields[required_name] += 1

    return {
        "repository": repository,
        "project_title": expected_title,
        "project_number": target["project_number"],
        "project_id": project.get("id"),
        "field_ids": field_ids,
        "resolved_field_names": resolved_names,
        "field_count": len(fields),
        "open_exact_items": len(exact_open_items),
        "status_counts": dict(status_counts),
        "missing_item_field_values": dict(missing_item_fields),
        "schema_mutations_allowed": False,
    }


def is_agent_pull_request(pull: dict[str, Any], target: dict[str, Any]) -> bool:
    prefixes = target.get("agent_head_prefixes", DEFAULT_AGENT_HEAD_PREFIXES)
    if not isinstance(prefixes, (list, tuple)) or not all(
        isinstance(prefix, str) and prefix for prefix in prefixes
    ):
        raise SnapshotError(
            "invalid_target",
            "agent_head_prefixes must be a list of non-empty strings",
        )
    head_ref = pull.get("head_ref") or (pull.get("head") or {}).get("ref")
    return isinstance(head_ref, str) and head_ref.startswith(tuple(prefixes))


def pull_request_detail(repository: str, pull: dict[str, Any]) -> dict[str, Any]:
    number = pull.get("number")
    if not isinstance(number, int):
        raise SnapshotError(
            "pull_projection_incomplete",
            "Open pull request was missing a numeric number",
            repository=repository,
        )
    endpoint = f"/repos/{repository}/pulls/{number}"
    detail: dict[str, Any] = {}
    for attempt in range(3):
        payload = gh_json(endpoint, attempts=2)
        if isinstance(payload, dict):
            detail = payload
        if detail.get("mergeable") is not None and isinstance(
            detail.get("mergeable_state"), str
        ):
            break
        if attempt < 2:
            time.sleep(0.25 * (attempt + 1))
    if detail.get("mergeable") is None or not isinstance(
        detail.get("mergeable_state"), str
    ):
        raise SnapshotError(
            "pull_projection_incomplete",
            "GitHub did not finish computing pull request mergeability",
            repository=repository,
            pull_number=number,
            endpoint=endpoint,
        )
    return {
        "number": number,
        "head_sha": (detail.get("head") or {}).get("sha"),
        "head_ref": (detail.get("head") or {}).get("ref"),
        "base_ref": (detail.get("base") or {}).get("ref"),
        "mergeable": detail["mergeable"],
        "mergeable_state": detail["mergeable_state"],
    }


def snapshot_pull_requests(
    target: dict[str, Any],
    *,
    max_workers: int,
) -> dict[str, Any]:
    repository = target.get("repository")
    if not isinstance(repository, str) or "/" not in repository:
        raise SnapshotError("invalid_target", "repository must be OWNER/REPO")

    repository_payload = gh_json(f"/repos/{repository}", attempts=2)
    default_branch = repository_payload.get("default_branch")
    if not isinstance(default_branch, str) or not default_branch:
        raise SnapshotError(
            "pull_projection_incomplete",
            "Repository default branch was unavailable",
            repository=repository,
        )

    pages = gh_json(
        f"/repos/{repository}/pulls?state=open&per_page=100",
        paginate=True,
        attempts=2,
    )
    open_pulls = [
        pull
        for pull in flatten_pages(pages)
        if not pull.get("draft")
        and (pull.get("base") or {}).get("ref") == default_branch
    ]

    details: list[dict[str, Any]] = []
    errors: list[dict[str, Any]] = []
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(pull_request_detail, repository, pull): pull
            for pull in open_pulls
        }
        for future in as_completed(futures):
            pull = futures[future]
            try:
                detail = future.result()
                detail["agent_authored"] = is_agent_pull_request(detail, target)
                details.append(detail)
            except SnapshotError as exc:
                errors.append(
                    {
                        "pull_number": pull.get("number"),
                        "kind": exc.kind,
                        "message": str(exc),
                        **exc.details,
                    }
                )

    details.sort(key=lambda pull: pull["number"])
    errors.sort(key=lambda error: error.get("pull_number") or 0)
    if errors:
        raise SnapshotError(
            "pull_projection_incomplete",
            "One or more open pull requests could not be projected completely",
            repository=repository,
            projected_pull_requests=details,
            pull_request_errors=errors,
        )

    agent_pulls = [pull for pull in details if pull["agent_authored"]]
    conflicted = [
        pull
        for pull in agent_pulls
        if not pull["mergeable"] or pull["mergeable_state"] == "dirty"
    ]
    return {
        "repository": repository,
        "default_branch": default_branch,
        "open_non_draft_count": len(details),
        "open_agent_count": len(agent_pulls),
        "conflicted_agent_count": len(conflicted),
        "complete": True,
        "pull_requests": details,
    }


def load_targets(path: Path) -> list[dict[str, Any]]:
    try:
        payload = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        raise SnapshotError("invalid_targets", f"Unable to read targets file {path}: {exc}") from exc
    if not isinstance(payload, list) or not payload:
        raise SnapshotError("invalid_targets", "Targets file must contain a non-empty array")
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--targets-file", type=Path, required=True)
    parser.add_argument(
        "--include-pull-requests",
        action="store_true",
        help="also project current open PR mergeability through bounded REST detail calls",
    )
    parser.add_argument(
        "--max-workers",
        type=int,
        default=DEFAULT_MAX_WORKERS,
        help=f"maximum concurrent PR detail requests (default: {DEFAULT_MAX_WORKERS})",
    )
    args = parser.parse_args()
    if args.max_workers < 1 or args.max_workers > 16:
        parser.error("--max-workers must be between 1 and 16")

    output: dict[str, Any] = {
        "api_version": API_VERSION,
        "snapshot_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
        "read_only": True,
        "schema_mutations_allowed": False,
        "projects": [],
        "pull_requests": [],
        "errors": [],
    }
    try:
        targets = load_targets(args.targets_file)
    except SnapshotError as exc:
        output["errors"].append({"kind": exc.kind, "message": str(exc), **exc.details})
        print(json.dumps(output, indent=2, sort_keys=True))
        return 2

    for target in targets:
        try:
            output["projects"].append(snapshot_target(target))
        except SnapshotError as exc:
            output["errors"].append(
                {
                    "repository": target.get("repository"),
                    "project_title": target.get("project_title"),
                    "kind": exc.kind,
                    "message": str(exc),
                    **exc.details,
                }
            )

    if args.include_pull_requests:
        for target in targets:
            try:
                output["pull_requests"].append(
                    snapshot_pull_requests(target, max_workers=args.max_workers)
                )
            except SnapshotError as exc:
                output["errors"].append(
                    {
                        "repository": target.get("repository"),
                        "project_title": target.get("project_title"),
                        "kind": exc.kind,
                        "message": str(exc),
                        **exc.details,
                    }
                )
        output["pull_requests"].sort(key=lambda item: item["repository"])

    expected_pull_snapshots = len(targets) if args.include_pull_requests else 0
    output["ok"] = (
        not output["errors"]
        and len(output["projects"]) == len(targets)
        and len(output["pull_requests"]) == expected_pull_snapshots
    )
    print(json.dumps(output, indent=2, sort_keys=True))
    return 0 if output["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
