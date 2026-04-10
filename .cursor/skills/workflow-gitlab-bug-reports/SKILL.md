---
name: workflow-gitlab-bug-reports
description: >-
  Triages GitLab issues and bug reports for this fork: fetch issue context, map affected
  code/SQL, scan recent GitHub pull requests on upstream repos, and verify commits before
  implementing locally. Use when the user references a GitLab issue, bug ticket, or MR,
  or asks to fix something reported on GitLab.
---

# GitLab bug reports and upstream sync

## Why

OMW work happens on **GitLab (origin)** while **AzerothCore and many modules track GitHub (upstream)**. Duplicating an upstream fix wastes time and can conflict at the next merge. Before writing a local fix, **check upstream** for **recent GitHub PRs**, commits, and issues that already address the same symptom.

## Workflow checklist

Copy and track when starting from a GitLab report:

```
GitLab bug triage:
- [ ] Load full issue context (GitLab MCP + links in description)
- [ ] Map symptom → subsystem (core C++, script, SQL, which module path)
- [ ] Resolve GitHub `owner/repo` for core + each affected module (from `git remote get-url`)
- [ ] Scan recent GitHub PRs (open + merged) on those repos for matching titles/keywords
- [ ] Fetch remotes and scan upstream `git log` for touched paths
- [ ] Note outcome: upstream PR or commit / partial / none / needs OMW-only change
- [ ] Choose: cherry-pick / port / fresh fix; document divergence
```

## 1. Issue context (GitLab)

Use **GitLab-MCP** when connected (see `.cursor/rules/mcp-usage.mdc`):

- `get_issue` — title, description, labels, links to MRs
- `list_issue_discussions` — reproduction steps, staff notes
- If an MR exists: `list_merge_requests` filters or links from issue; `get_merge_request_diffs` for proposed changes

If MCP is unavailable, use the GitLab web UI URL the user provided; do not invent issue text.

## 2. Map scope

From the report, decide:

| Area | Typical paths |
|------|----------------|
| Core / scripts | `src/server/`, `src/common/` |
| World DB | `data/sql/`, `acore_world` content |
| Auth / characters | `data/sql/` under auth/characters, module SQL |
| A module | `modules/<name>/` (often its **own** git remote) |

Bugs may span **root repo + one or more modules** — check each subtree that plausibly owns the behavior.

## 3. Upstream check (required before implementation)

### Root repository (AzerothCore)

In the **core repo** checkout:

```bash
cd /root/azerothcore-wotlk   # or actual clone root
git remote -v
git fetch upstream 2>/dev/null || true
git fetch origin
```

- If `upstream` points at **github.com/azerothcore/azerothcore-wotlk** (or your documented upstream), compare the branch you merge from (often `master`):

```bash
# Example: commits on upstream touching suspected areas (adjust branch + paths)
git log --oneline upstream/master -n 30 -- src/server/game/Spells/
git log --oneline upstream/master --grep="keyword from issue" -n 20
```

- If **no `upstream` remote**, add it per team docs or use `git ls-remote` against the public repo only for read-only comparison — do not assume remotes; run `git remote -v` and adapt.

### Modules (`modules/*`)

Many modules are **nested repos**:

```bash
cd modules/<relevant-module>
git remote -v
git fetch upstream 2>/dev/null || git fetch origin
git log --oneline upstream/master -n 30 -- .
# or: git log --oneline origin/main -n 30 -- .
```

Use the remote name that actually tracks **GitHub upstream** for that module (often `upstream` or `origin` depending on how the submodule was cloned).

### Recent GitHub pull requests (required)

GitLab MRs are **not** upstream AzerothCore. For each **GitHub** repo that owns the code (core + every relevant module), review **recent PRs** so you do not miss fixes that are merged, still open, or in review.

1. **Resolve `OWNER/REPO`** from the remote URL (same remote you treat as upstream), e.g. `azerothcore/azerothcore-wotlk` or `azerothcore/mod-playerbots`.

2. **GitHub CLI** (preferred when `gh` is available and authenticated — run from any directory):

```bash
# Open PRs first (in-flight work you might align with or duplicate)
gh pr list -R OWNER/REPO --state open --limit 30

# Recently merged (adjust --search with tokens from the bug: spell id, NPC name, subsystem)
gh pr list -R OWNER/REPO --state merged --limit 25 --search "keyword"

# Machine-readable skim (title + URL + dates)
gh pr list -R OWNER/REPO --state all --limit 30 --json number,title,state,url,updatedAt,mergedAt
```

Use several **short searches** (spell ID, map name, crash frame, file basename) rather than one long sentence. Repeat for **each** related repo (core and modules).

3. **Without `gh`**: open or **fetch** the GitHub PR list URL (sorted by recency), e.g.  
   `https://github.com/OWNER/REPO/pulls?q=is%3Apr+sort%3Aupdated-desc+`  
   append keywords (`+` separated) or use GitHub’s search on that repo’s Pull requests tab.

4. **Optional**: **GitHub MCP** (`github-mcp-server`) if enabled in your Cursor config — use it to search or list PRs per that server’s tools instead of guessing API results.

5. If a PR looks relevant, open the PR or use **fetch** on the PR URL; note PR number and merge status in your GitLab note.

### What to look for (commits + PRs together)

- **PR titles and descriptions** matching the symptom, IDs, or area (often clearer than commit subjects)
- Recent commits touching the same **files**, **spell IDs**, **NPC entry**, **quest ID**, or **crash stack** symbols
- Upstream **GitHub issues** linked from those PRs; **deepwiki** `ask_question` on `owner/repo` when git/PR UI is inconclusive
- Matching **SQL** in upstream `data/sql/updates/` for the same table/row class of bug

### If upstream already fixed it

- Prefer **cherry-pick** or **merge from upstream** per normal OMW process; resolve conflicts with OMW patches documented in commit messages or MR description.
- Avoid reimplementing the same logic differently unless there is a documented OMW requirement.

### If upstream has no fix

- Implement locally; keep the fix **minimal** and note in GitLab that upstream was checked (branch name + date optional) so future merges stay predictable.

## 4. Deepwiki / web (optional)

When **PR lists** and `git log` are inconclusive:

- **deepwiki** tools: questions against `azerothcore/azerothcore-wotlk` or module repos
- **fetch**: specific GitHub issue/PR/commit URLs once you have candidates from `gh` or the PR list

## 5. GitLab follow-up

After analysis, update the issue or MR (when policy allows) with a short note:

- Upstream: found commit / PR link / not found
- Planned approach: cherry-pick SHA vs new fix

## Related

- Git / merge expectations: `CLAUDE.md` (Staying current with upstream), `.cursor/rules/azerothcore-standards.mdc`
- **MCP routing**: `.cursor/rules/mcp-usage.mdc`, `.cursor/reference/mcp-tools-inventory.md`
