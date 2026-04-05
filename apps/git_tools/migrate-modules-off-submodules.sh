#!/usr/bin/env bash

set -euo pipefail

ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../"
MANIFEST_PATH="$ROOT_PATH/apps/git_tools/modules.manifest"
GITMODULES_PATH="$ROOT_PATH/.gitmodules"
GITIGNORE_PATH="$ROOT_PATH/.gitignore"

apply_changes=0
declare -a selected_modules=()

usage() {
  cat <<'EOF'
Usage: migrate-modules-off-submodules.sh [options]

Prepare or execute the migration from submodule-pinned module gitlinks to
independently managed module repositories.

Default mode is dry-run. Use `--apply` to make changes.

Options:
  --module NAME          Migrate only the named module (repeatable)
  --apply                Apply changes instead of printing the plan
  -h, --help             Show this help

What the script does:
  - validates each selected module exists as a Git repo
  - converts submodule gitfile metadata to a standalone .git directory when needed
  - removes module gitlinks from the superproject index with `git rm --cached`
  - removes matching entries from `.gitmodules`
  - prints the `.gitignore` rules needed so module repos stop showing up as
    pinned gitlinks in the superproject

What it does not do:
  - it does not delete module working trees
  - it does not commit anything
  - it does not overwrite dirty module repos
EOF
}

log() {
  printf '[migrate] %s\n' "$*"
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

list_modules_from_manifest() {
  awk 'NF >= 3 && $1 !~ /^#/ { print $1 "\t" $2 "\t" $3 }' "$MANIFEST_PATH"
}

ensure_standalone_gitdir() {
  local repo_path="$1"
  local module_name="$2"
  local repo_url="$3"

  if [[ -d "$repo_path/.git" ]]; then
    return 0
  fi

  if [[ -f "$repo_path/.git" ]]; then
    local real_git_dir
    real_git_dir="$(git -C "$repo_path" rev-parse --git-dir)"
    real_git_dir="$(cd "$repo_path" && cd "$real_git_dir" && pwd)"

    log "$module_name uses gitfile metadata -> $real_git_dir"

    if [[ "$apply_changes" -eq 0 ]]; then
      log "$module_name dry-run: would copy $real_git_dir to $repo_path/.git"
      return 0
    fi

    rm -f "$repo_path/.git"
    cp -a "$real_git_dir" "$repo_path/.git"
    git -C "$repo_path" config --unset core.worktree >/dev/null 2>&1 || true
    return 0
  fi

  if [[ -n "$(find "$repo_path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    warn "$module_name has no .git metadata at $repo_path"
    return 1
  fi

  if [[ -z "$repo_url" ]]; then
    warn "$module_name has no .git metadata and no manifest URL"
    return 1
  fi

  log "$module_name has no local git metadata; will clone from $repo_url"

  if [[ "$apply_changes" -eq 0 ]]; then
    log "$module_name dry-run: would clone $repo_url into $repo_path"
    return 0
  fi

  rm -rf "$repo_path"
  git clone "$repo_url" "$repo_path"
}

remove_gitlink_from_index() {
  local module_path="$1"
  local module_name="$2"

  if ! git -C "$ROOT_PATH" ls-files --stage -- "$module_path" | grep -q '^160000 '; then
    log "$module_name is not a gitlink in the current index, skipping git rm --cached"
    return 0
  fi

  if [[ "$apply_changes" -eq 0 ]]; then
    log "$module_name dry-run: would run git rm --cached -f -- $module_path"
    return 0
  fi

  git -C "$ROOT_PATH" rm --cached -f -- "$module_path"
}

remove_gitmodules_entry() {
  local module_path="$1"
  local section="submodule.${module_path}"

  if ! git -C "$ROOT_PATH" config --file .gitmodules --get-regexp "^${section//./\\.}\\.(path|url)$" >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$apply_changes" -eq 0 ]]; then
    log "$module_path dry-run: would remove section [$section] from .gitmodules"
    return 0
  fi

  git -C "$ROOT_PATH" config --file .gitmodules --remove-section "$section"
  git -C "$ROOT_PATH" add .gitmodules
}

print_gitignore_plan() {
  cat <<'EOF'

Suggested .gitignore block for independent module repos:

/modules/*
!/modules/.gitkeep
!/modules/CMakeLists.txt
!/modules/ModulesLoader.cpp.in.cmake
!/modules/ModulesPCH.h
!/modules/ModulesScriptLoader.h
!/modules/create_module.sh
!/modules/how_to_make_a_module.md

EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --module)
      shift
      if [[ $# -eq 0 ]]; then
        warn "--module requires a value"
        exit 1
      fi
      selected_modules+=("$1")
      ;;
    --apply)
      apply_changes=1
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

log "manifest: $MANIFEST_PATH"
log "mode: $([[ "$apply_changes" -eq 1 ]] && echo apply || echo dry-run)"

while IFS=$'\t' read -r module_name module_path module_url; do
  if ! is_selected_module "$module_name"; then
    continue
  fi

  full_path="$ROOT_PATH/$module_path"

  if [[ ! -d "$full_path" ]]; then
    warn "$module_name missing at $full_path"
    continue
  fi

  if [[ -d "$full_path/.git" || -f "$full_path/.git" ]]; then
    if [[ -n "$(git -C "$full_path" status --porcelain)" ]]; then
      warn "$module_name has local changes; migration does not touch its worktree"
    fi
  elif [[ -n "$(find "$full_path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    warn "$module_name has local changes; migration does not touch its worktree"
  fi

  log "$module_name -> $module_path ($module_url)"
  ensure_standalone_gitdir "$full_path" "$module_name" "$module_url"
  remove_gitlink_from_index "$module_path" "$module_name"
  remove_gitmodules_entry "$module_path"
done < <(list_modules_from_manifest)

if [[ "$apply_changes" -eq 1 ]] && [[ -f "$GITMODULES_PATH" ]]; then
  if ! git -C "$ROOT_PATH" config --file .gitmodules --get-regexp '^submodule\..*\.path$' >/dev/null 2>&1; then
    log "no submodule entries remain in .gitmodules"
  fi
fi

print_gitignore_plan

if [[ "$apply_changes" -eq 0 ]]; then
  log "dry-run complete; rerun with --apply to make index and .gitmodules changes"
else
  log "apply complete; review .gitmodules, .gitignore, and the staged removals before committing"
fi