# Upstream merge plan

Prepare a **safe merge or rebase plan** from **GitHub upstream** into our **GitLab** workflow for:

- The **core** repo, and/or
- One or more **`modules/*`** sub-repositories (each may have its own remotes).

Output:

1. Which directories need `git` operations (root vs module paths).
2. Suggested order (modules first vs core first) and why.
3. Likely conflict zones (custom patches, playerbots, SQL).
4. Post-merge checklist: compile, SQL updates, log check.

Invoke the **upstream-merge-advisor** subagent if a deep pass is needed. Use **GitLab-MCP** (`list_merge_requests`, `get_merge_request_diffs`, `get_file_contents`) and **GitHub MCP** (if enabled) for live remote state; **azerothcore** `search_azerothcore_source` for overlap with upstream. See `.cursor/reference/mcp-tools-inventory.md`.

Do not run destructive git commands without explicit user confirmation.
