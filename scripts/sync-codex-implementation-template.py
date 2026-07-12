#!/usr/bin/env python3
"""Keep the app-ready issue implementation TOML synced with its canonical prompt."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROMPT = ROOT / "shared/local/codex/github-issue-implementation.prompt.md"
TEMPLATE = ROOT / "codex/automations/local/github-issue-implementation/automation.toml"
PROMPT_BLOCK = re.compile(r'prompt = """\n.*?\n"""', re.DOTALL)


def expected_block() -> str:
    return f'prompt = """\n{PROMPT.read_text().rstrip()}\n"""'


def synchronized_text() -> str:
    current = TEMPLATE.read_text()
    updated, count = PROMPT_BLOCK.subn(lambda _: expected_block(), current, count=1)
    if count != 1:
        raise SystemExit(f"could not locate one prompt block in {TEMPLATE}")
    return updated


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail when generated prompt content is stale")
    args = parser.parse_args()

    current = TEMPLATE.read_text()
    updated = synchronized_text()
    if args.check:
        if current != updated:
            print(f"stale generated prompt: {TEMPLATE}")
            return 1
        print("OK: implementation prompt is synchronized")
        return 0

    TEMPLATE.write_text(updated)
    print(f"updated {TEMPLATE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
