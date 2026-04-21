#!/usr/bin/env python3
"""Cursor beforeShellExecution hook: surface-risky shell commands (fail-open)."""
from __future__ import annotations

import json
import re
import sys

# (regex, human label) — keep patterns conservative to limit false positives.
PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"\bgit\b.+?\bpush\b.+?--force", re.I), "git push --force"),
    (re.compile(r"\brm\b.+?-\w*f\w*", re.I), "rm with force flags"),
    (re.compile(r"\bmysql\b.+?\bDROP\b.+\bDATABASE\b", re.I), "MySQL DROP DATABASE"),
    (re.compile(r"\bmysqladmin\b.+?\bdrop\b", re.I), "mysqladmin drop"),
]


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        print('{"permission":"allow"}', flush=True)
        return

    cmd = (
        data.get("command")
        or data.get("shell_command")
        or data.get("cmd")
        or ""
    )
    if not isinstance(cmd, str):
        cmd = str(cmd)
    cmd = cmd.strip()
    if not cmd:
        print('{"permission":"allow"}', flush=True)
        return

    for pattern, label in PATTERNS:
        if pattern.search(cmd):
            out = {
                "permission": "ask",
                "user_message": (
                    f"Project shell hook flagged “{label}”. "
                    "Confirm this is intentional before running."
                ),
                "agent_message": f"shell_guard.py matched: {label}",
            }
            print(json.dumps(out), flush=True)
            return

    print('{"permission":"allow"}', flush=True)


if __name__ == "__main__":
    main()
