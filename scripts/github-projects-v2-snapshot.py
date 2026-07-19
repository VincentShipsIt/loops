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
from collections import Counter
from pathlib import Path
from typing import Any


API_VERSION = "2026-03-10"
DEFAULT_GH = "/opt/homebrew/bin/gh"


class SnapshotError(RuntimeError):
    """A bounded snapshot failed or was incomplete."""

    def __init__(self, kind: str, message: str, **details: Any) -> None:
        super().__init__(message)
        self.kind = kind
        self.details = details


def gh_path() -> str:
    return shutil.which("gh") or DEFAULT_GH


def gh_json(endpoint: str, *, paginate: bool = False) -> Any:
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
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=False)
    except OSError as exc:
        raise SnapshotError("transport_failure", f"Unable to execute gh: {exc}") from exc
    if result.returncode != 0:
        raise SnapshotError(
            "api_failure",
            f"GitHub REST request failed for {endpoint}",
            endpoint=endpoint,
            detail=result.stderr.strip()[:500],
        )
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise SnapshotError(
            "invalid_response",
            f"GitHub REST response was not JSON for {endpoint}",
            endpoint=endpoint,
        ) from exc


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
    args = parser.parse_args()

    output: dict[str, Any] = {
        "api_version": API_VERSION,
        "snapshot_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
        "read_only": True,
        "schema_mutations_allowed": False,
        "projects": [],
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

    output["ok"] = not output["errors"] and len(output["projects"]) == len(targets)
    print(json.dumps(output, indent=2, sort_keys=True))
    return 0 if output["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
