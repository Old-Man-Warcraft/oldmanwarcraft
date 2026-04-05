#!/usr/bin/env python3
"""
Write ~/.cursor/mcp.json from azerothcore-wotlk/.cursor/reference/mcp.base.json,
injecting secrets from ~/.cursor/mcp.secrets.env.

Why: Cursor often does not expand ${env:VAR} when launched from the GUI, and
URL-based MCP headers may not interpolate env vars. The base file uses a wrapper
script that sources mcp.secrets.env before npx/uvx; OMW header is filled here.

Usage:
  python3 .cursor/scripts/regenerate_mcp_json.py
  python3 .cursor/scripts/regenerate_mcp_json.py --dry-run
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def load_secrets(path: Path) -> dict[str, str]:
    if not path.is_file():
        print(f"Missing secrets file: {path}", file=sys.stderr)
        print("Create it from .cursor/reference/mcp.env.example (KEY=value lines).", file=sys.stderr)
        sys.exit(1)
    out: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[7:].strip()
        if "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        out[key] = val
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Print JSON to stdout only")
    args = parser.parse_args()

    home = Path.home()
    secrets_path = home / ".cursor" / "mcp.secrets.env"
    wrap = str(home / ".cursor" / "mcp-exec-with-secrets.sh")

    repo_root = Path(__file__).resolve().parents[2]
    base_path = repo_root / ".cursor" / "reference" / "mcp.base.json"
    if not base_path.is_file():
        print(f"Missing base template: {base_path}", file=sys.stderr)
        sys.exit(1)

    secrets = load_secrets(secrets_path)
    with base_path.open(encoding="utf-8") as f:
        cfg = json.load(f)

    def inject_wrap(obj: object) -> None:
        if isinstance(obj, dict):
            for k, v in obj.items():
                if v == "__MCP_WRAP__":
                    obj[k] = wrap
                else:
                    inject_wrap(v)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                if item == "__MCP_WRAP__":
                    obj[i] = wrap
                else:
                    inject_wrap(item)

    inject_wrap(cfg)

    servers = cfg.setdefault("mcpServers", {})

    def need(key: str) -> str:
        v = secrets.get(key, "").strip()
        if not v:
            print(f"Warning: {key} is empty in {secrets_path}", file=sys.stderr)
        return v

    # Remote OMW: header must be literal in JSON (no reliable env interpolation).
    omw = servers.get("oldmanwarcraft-api-remote")
    if isinstance(omw, dict) and omw.get("headers"):
        omw["headers"]["X-API-Key"] = need("OLDMANWARCRAFT_MCP_API_KEY")

    # Optional: GitHub Docker — token passed in generated JSON env (child is docker, not our wrapper).
    gh = servers.get("github-mcp-server")
    if isinstance(gh, dict) and "env" in gh:
        tok = secrets.get("GITHUB_PERSONAL_ACCESS_TOKEN", "").strip()
        if tok:
            gh["env"]["GITHUB_PERSONAL_ACCESS_TOKEN"] = tok
        elif not gh.get("disabled", False):
            print("Warning: GITHUB_PERSONAL_ACCESS_TOKEN empty; GitHub MCP may fail.", file=sys.stderr)

    # Ensure wrapper path exists
    if not Path(wrap).is_file():
        print(f"Warning: wrapper missing: {wrap}", file=sys.stderr)

    out = json.dumps(cfg, indent=2) + "\n"
    if args.dry_run:
        print(out)
        return

    out_path = home / ".cursor" / "mcp.json"
    out_path.write_text(out, encoding="utf-8")
    out_path.chmod(0o600)
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
