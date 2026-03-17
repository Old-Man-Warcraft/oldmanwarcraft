#!/usr/bin/env bash

set -euo pipefail

ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../"
MANIFEST_PATH="$ROOT_PATH/apps/git_tools/modules.manifest"

update_main=1
update_modules=1
fetch_only=0
clone_missing=0
declare -a selected_modules=()

usage() {
  cat <<'EOF'
Usage: independent-repo-update.sh [options]

Update the main repository and initialized module repositories independently.
Unlike `git submodule update`, this does not reset modules to the superproject's
pinned gitlink commit.

Module discovery is driven by `apps/git_tools/modules.manifest`, so this script
continues to work even after moving away from `.gitmodules`.

Options:
  --main-only            Update only the main repo
  --modules-only         Update only module repos
  --module NAME          Update only the named module (repeatable)
  --fetch-only           Fetch only, never pull
  --clone-missing        Clone modules listed in the manifest when absent
  -h, --help             Show this help

Behavior:
  - Fetches all repos first
  - Pulls only when the repo is on a branch, has an upstream, and is clean
  - Uses `git pull --ff-only` to avoid merge commits
  - Skips dirty repos instead of overwriting local work
EOF
}

log() {
  printf '[sync] %s\n' "$*"
}

warn() {
  printf '[warn] %s\n' "$*" >&2
}

is_selected_module() {
  local module_name="$1"

  if [[ ${#selected_modules[@]} -eq 0 ]]; then
    return 0
  fi

  local selected
  for selected in "${selected_modules[@]}"; do
    if [[ "$selected" == "$module_name" ]]; then
      return 0
    fi
  done

  return 1
}

ensure_repo_exists() {
  local repo_path="$1"
  local repo_name="$2"
  local repo_url="$3"

  if git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$clone_missing" -eq 0 ]]; then
    warn "$repo_name is not initialized, skipping"
    return 1
  fi

  if [[ -z "$repo_url" ]]; then
    warn "$repo_name has no manifest URL, skipping clone"
    return 1
  fi

  log "$repo_name: cloning $repo_url into $repo_path"
  mkdir -p "$(dirname "$repo_path")"
  git clone "$repo_url" "$repo_path"
}

update_repo() {
  local repo_path="$1"
  local repo_name="$2"
  local repo_url="${3:-}"

  if ! ensure_repo_exists "$repo_path" "$repo_name" "$repo_url"; then
    return 0
  fi

  local branch upstream dirty divergence fetch_ref
  branch="$(git -C "$repo_path" symbolic-ref --quiet --short HEAD || true)"

  if [[ -z "$branch" ]]; then
    warn "$repo_name is in detached HEAD, fetching only"
    git -C "$repo_path" fetch --all --prune
    return 0
  fi

  dirty="$(git -C "$repo_path" status --porcelain)"
  upstream="$(git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"

  if [[ -n "$upstream" ]]; then
    fetch_ref="${upstream#*/}"
    log "$repo_name: fetching $branch from ${upstream%%/*}"
    git -C "$repo_path" fetch "${upstream%%/*}" "$fetch_ref" --prune
  else
    warn "$repo_name has no upstream configured, fetching all remotes only"
    git -C "$repo_path" fetch --all --prune
  fi

  if [[ -z "$upstream" ]]; then
    return 0
  fi

  divergence="$(git -C "$repo_path" rev-list --left-right --count HEAD...@{upstream})"
  log "$repo_name: divergence HEAD...@{upstream} = $divergence"

  if [[ "$fetch_only" -eq 1 ]]; then
    return 0
  fi

  if [[ -n "$dirty" ]]; then
    warn "$repo_name has local changes, skipping pull"
    return 0
  fi

  log "$repo_name: pulling $branch with --ff-only"
  git -C "$repo_path" pull --ff-only
}

list_modules_from_manifest() {
  awk 'NF >= 3 && $1 !~ /^#/ { print $1 "\t" $2 "\t" $3 }' "$MANIFEST_PATH"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-only)
      update_main=1
      update_modules=0
      ;;
    --modules-only)
      update_main=0
      update_modules=1
      ;;
    --module)
      shift
      if [[ $# -eq 0 ]]; then
        warn "--module requires a value"
        exit 1
      fi
      selected_modules+=("$1")
      ;;
    --fetch-only)
      fetch_only=1
      ;;
    --clone-missing)
      clone_missing=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$update_main" -eq 1 ]]; then
  update_repo "$ROOT_PATH" "main repo"
fi

if [[ "$update_modules" -eq 1 ]]; then
  while IFS=$'\t' read -r module_name module_path module_url; do
    if ! is_selected_module "$module_name"; then
      continue
    fi

    update_repo "$ROOT_PATH/$module_path" "$module_name" "$module_url"
  done < <(list_modules_from_manifest)
fi