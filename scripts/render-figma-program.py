#!/usr/bin/env python3
"""Render allowlisted Figma Plugin API programs with validated JSON input."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
PROGRAM_ROOT = REPOSITORY_ROOT / "figma" / "surface-orchestrator"
CATALOG_PATH = PROGRAM_ROOT / "programs.json"
FORBIDDEN_SOURCE = ("figma.closePlugin(", "figma.notify(")


def fail(message: str) -> "NoReturn":
    raise ValueError(message)


def sha256(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def load_catalog() -> dict[str, Any]:
    try:
        catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read catalog {CATALOG_PATH}: {error}")
    if catalog.get("version") != 1:
        fail("catalog version must be 1")
    if not isinstance(catalog.get("inputMarker"), str) or not catalog["inputMarker"]:
        fail("catalog inputMarker must be a non-empty string")
    if not isinstance(catalog.get("programs"), dict) or not catalog["programs"]:
        fail("catalog programs must be a non-empty object")
    return catalog


def resolve_program(
    catalog: dict[str, Any], program_id: str
) -> tuple[dict[str, Any], Path, str]:
    entry = catalog["programs"].get(program_id)
    if not isinstance(entry, dict):
        fail(f"unknown program id: {program_id}")
    relative_path = entry.get("path")
    if not isinstance(relative_path, str) or not relative_path:
        fail(f"{program_id}: path must be a non-empty string")

    root = PROGRAM_ROOT.resolve()
    path = (PROGRAM_ROOT / relative_path).resolve()
    try:
        path.relative_to(root)
    except ValueError:
        fail(f"{program_id}: program path escapes {PROGRAM_ROOT}")
    if not path.is_file():
        fail(f"{program_id}: missing program file {relative_path}")

    source = path.read_text(encoding="utf-8")
    marker = catalog["inputMarker"]
    if source.count(marker) != 1:
        fail(f"{program_id}: source must contain exactly one input marker")
    for forbidden in FORBIDDEN_SOURCE:
        if forbidden in source:
            fail(f"{program_id}: forbidden source call {forbidden}")

    operation = entry.get("operation")
    if operation not in {"read", "write"}:
        fail(f"{program_id}: operation must be read or write")
    description = entry.get("description")
    if not isinstance(description, str) or not description:
        fail(f"{program_id}: description must be a non-empty string")

    required = entry.get("requiredInput", [])
    allowed = entry.get("allowedInput", [])
    if (
        not isinstance(required, list)
        or not all(isinstance(value, str) and value for value in required)
        or len(required) != len(set(required))
    ):
        fail(f"{program_id}: requiredInput must contain unique non-empty strings")
    if (
        not isinstance(allowed, list)
        or not all(isinstance(value, str) and value for value in allowed)
        or len(allowed) != len(set(allowed))
    ):
        fail(f"{program_id}: allowedInput must contain unique non-empty strings")
    if not set(required).issubset(allowed):
        fail(f"{program_id}: requiredInput must be a subset of allowedInput")
    return entry, path, source


def load_input(args: argparse.Namespace) -> dict[str, Any]:
    if args.input_file and args.input_json is not None:
        fail("use only one of --input-file or --input-json")
    try:
        if args.input_file:
            value = json.loads(Path(args.input_file).read_text(encoding="utf-8"))
        else:
            value = json.loads(args.input_json if args.input_json is not None else "{}")
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read input JSON: {error}")
    if not isinstance(value, dict):
        fail("input JSON must be an object")
    return value


def render(
    catalog: dict[str, Any], program_id: str, input_value: dict[str, Any]
) -> tuple[str, dict[str, Any]]:
    entry, path, source = resolve_program(catalog, program_id)
    required = set(entry.get("requiredInput", []))
    allowed = set(entry.get("allowedInput", []))
    missing = sorted(required - input_value.keys())
    unknown = sorted(input_value.keys() - allowed)
    if missing:
        fail(f"{program_id}: missing required input fields: {', '.join(missing)}")
    if unknown:
        fail(f"{program_id}: unknown input fields: {', '.join(unknown)}")

    serialized_input = json.dumps(
        input_value, ensure_ascii=False, separators=(",", ":"), sort_keys=True
    )
    rendered = source.replace(
        catalog["inputMarker"], f"const INPUT = {serialized_input};"
    )
    metadata = {
        "programId": program_id,
        "operation": entry["operation"],
        "description": entry["description"],
        "sourcePath": str(path.relative_to(REPOSITORY_ROOT)),
        "sourceSha256": sha256(source),
        "renderedSha256": sha256(rendered),
        "requiredInput": entry.get("requiredInput", []),
        "allowedInput": entry.get("allowedInput", []),
    }
    return rendered, metadata


def check_catalog(catalog: dict[str, Any]) -> None:
    for program_id in sorted(catalog["programs"]):
        resolve_program(catalog, program_id)
    print(f"OK: {len(catalog['programs'])} Figma programs")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("program_id", nargs="?")
    parser.add_argument("--input-file")
    parser.add_argument("--input-json")
    parser.add_argument(
        "--format",
        choices=("code", "metadata", "envelope"),
        default="code",
        help="output rendered code, ledger metadata, or both as JSON",
    )
    parser.add_argument("--check", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        catalog = load_catalog()
        if args.check:
            if args.program_id or args.input_file or args.input_json is not None:
                fail("--check does not accept a program id or input")
            check_catalog(catalog)
            return 0
        if not args.program_id:
            fail("program_id is required unless --check is used")

        input_value = load_input(args)
        rendered, metadata = render(catalog, args.program_id, input_value)
        if args.format == "code":
            print(rendered)
        elif args.format == "metadata":
            print(json.dumps(metadata, indent=2, sort_keys=True))
        else:
            print(
                json.dumps(
                    {"code": rendered, "metadata": metadata},
                    indent=2,
                    sort_keys=True,
                )
            )
        return 0
    except ValueError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
