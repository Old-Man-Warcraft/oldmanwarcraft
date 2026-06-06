---
description: Merge upstream changes into main, preserving all local customizations
---

# Merge Day Workflow

This workflow merges updates from upstream sources into our `main` branch and into each module that has an `upstream` remote, preserving all local customizations.

**Core repo remotes:**
- `upstream` → https://github.com/mod-playerbots/azerothcore-wotlk (Playerbot — **primary merge source**)
- `origin` → https://github.com/Old-Man-Warcraft/oldmanwarcraft.git (our fork)
- `oldman-gl` → GitLab production mirror

> **Note:** We do NOT merge directly from `azerothcore/master`. The `upstream/Playerbot` branch already tracks AzerothCore upstream and merges it in.

**Modules with upstream remotes** (each is an independent git repo in `modules/`):
- `mod-globalchat` — upstream: https://github.com/Gozzim/mod-globalchat
- `mod-guild-village` — upstream: https://github.com/Old-Man-Warcraft/mod-guild-village.git
- `mod-item-upgrade` — upstream: https://github.com/silviu20092/mod-item-upgrade
- `mod-ollama-chat` — upstream: https://github.com/DustinHendrickson/mod-ollama-chat
- `mod-playerbots` — upstream: https://github.com/mod-playerbots/mod-playerbots.git
- `mod-premium` — upstream: https://github.com/talamortis/mod-premium.git
- `mod-transmog` — upstream: https://github.com/azerothcore/mod-transmog

---

## Pre-Merge Checklist

1. Confirm you are on the `main` branch and it is clean:
```bash
git status
git checkout main
```

2. Confirm no uncommitted local changes (stash if needed):
```bash
git stash
```

3. Create a dated backup branch before any merge:
```bash
git branch backup/pre-upstream-merge-$(date +%Y-%m-%d-%H%M%S)-main
```

---

## Step 1: Fetch All Upstreams

Fetch the latest from all remotes without modifying local branches:

```bash
git fetch upstream
git fetch origin
```

---

## Step 2: Review What Has Changed

Check what commits exist upstream that we don't have yet:

```bash
# Playerbot upstream changes since our last merge
git log main..upstream/Playerbot --oneline
```

Review any files changed that overlap with our custom work:

```bash
# Files changed in upstream/Playerbot vs our main
git diff --name-only main upstream/Playerbot
```

---

## Step 3: Merge Playerbot Upstream

Merge the Playerbot upstream branch into `main`:

```bash
git merge upstream/Playerbot --no-ff -m "merge(Playerbots): merge upstream/Playerbot into main"
```

**If conflicts arise:**
- Resolve playerbot conflicts carefully — prefer our local fixes (threading patches, safety fixes) over upstream
- Check `modules/mod-playerbots/` specifically — this is a nested submodule/repo, handle separately in Step 4

---

## Step 4: Merge Module Upstreams

Each module in `modules/` is an independent git repository. For every module that has an `upstream` remote, fetch and merge upstream changes while preserving local customizations.

### Quick check — which modules have an upstream?

```bash
for mod in modules/mod-*/; do
  name=$(basename $mod)
  if git -C "$mod" remote | grep -q upstream; then
    echo "$name has upstream: $(git -C $mod remote get-url upstream)"
  fi
done
```

### For each module with an upstream remote:

```bash
# Set MOD to the module directory name, e.g. mod-playerbots
MOD=mod-playerbots
cd modules/$MOD

# 1. Check current branch and status
git status
git branch

# 2. Create a backup branch
git branch backup/pre-upstream-merge-$(date +%Y-%m-%d-%H%M%S)

# 3. Fetch upstream
git fetch upstream

# 4. Preview what's new
git log HEAD..upstream/<branch> --oneline
git diff --name-only HEAD upstream/<branch>

# 5. Merge, preferring our local changes on conflict
git merge upstream/<branch> --no-ff -m "merge($MOD): merge upstream into $(git branch --show-current)"

# 6. Resolve conflicts if any, then:
git add <resolved-files>
git merge --continue

# 7. Push to our remote
git push origin $(git branch --show-current)

cd ../..
```

### Module-specific notes:

| Module | Upstream Branch | Our Branch | Notes |
|---|---|---|---|
| `mod-playerbots` | `master` | `master` | High-risk — always review diff carefully, prefer our safety/threading fixes |
| `mod-transmog` | `master` | `master` | Generally safe, low customization |
| `mod-item-upgrade` | `master` | `feature/integrations` | We are on a custom branch — merge carefully |
| `mod-globalchat` | (check upstream) | `HEAD` | Detached HEAD — checkout a named branch first |
| `mod-ollama-chat` | `main` | `main` | Low customization, generally safe |
| `mod-premium` | `master` | `master` | Review upstream changes before merging |
| `mod-guild-village` | `main` | `main` | Check diff carefully for our custom changes |

### Conflict resolution rule for all modules:
- **Always prefer our local changes** when in doubt
- Never blindly accept upstream changes that touch files we have customized
- If uncertain, use `git diff upstream/<branch> HEAD -- <file>` to compare

---

## Step 5: Verify Build Integrity

After all merges complete, verify the tree is in a good state:

```bash
# Check for leftover conflict markers
grep -r "<<<<<<" src/ modules/ --include="*.cpp" --include="*.h" -l

# Confirm submodules are consistent
git submodule status
```

Optionally trigger a local build to confirm no compilation errors before pushing.

---

## Step 6: Push to Remotes

Push `main` to both GitHub and GitLab:

```bash
git push origin main
git push oldman-gl main
```

If GitLab requires force (after rebase scenarios):
```bash
git push oldman-gl main --force-with-lease
```

---

## Step 7: Post-Merge Notes

- Tag the merge in your notes with date and commit hashes of what was pulled from core and each module
- Check backup branches are still intact: `git branch | grep backup` (in core and each module)
- Review the crash/bug tracker for any issues the upstream may have fixed or introduced
- If a module that previously had no `upstream` remote now needs one, add it with `git -C modules/<mod> remote add upstream <url>`

---

## Rollback

If the merge causes critical issues, reset to the backup branch:

```bash
git reset --hard backup/pre-upstream-merge-<timestamp>-main
git push origin main --force-with-lease
git push oldman-gl main --force-with-lease
```
