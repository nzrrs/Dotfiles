#!/usr/bin/env bash

set -u
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$SCRIPT_DIR")"
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-installer"
readonly MANIFEST_PATH="$STATE_DIR/manifest.tsv"

GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'

TOTAL_STEPS=1
CURRENT_STEP=0
ERROR_COUNT=0

INSTALL_METHOD="unknown"

declare -a MANAGED_ENTRIES=()
declare -a PACKAGE_NAMES=()
declare -a INSTALLED_PACKAGES=()
declare -a CANDIDATE_LINKS=()
declare -a CREATED_DIRS=()
declare -a STOW_PREVIEW_ITEMS=()

print_error() {
  printf '\n%sError:%s %s\n' "$RED" "$RESET" "$*" >&2
}

print_warn() {
  printf '\n%sWarning:%s %s\n' "$YELLOW" "$RESET" "$*"
}

draw_progress() {
  local operation="$1"
  local cols bar_width fill empty percent bar

  cols="$(tput cols 2>/dev/null || printf '80\n')"
  bar_width=$((cols - 45))
  if (( bar_width < 10 )); then
    bar_width=10
  fi

  percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
  fill=$((bar_width * CURRENT_STEP / TOTAL_STEPS))
  empty=$((bar_width - fill))

  bar="$(printf '%*s' "$fill" '' | tr ' ' '=')"
  bar+=$(printf '%*s' "$empty" '' | tr ' ' '-')

  printf '\r\033[2K%s[%s] %3d%%%s %s' "$GREEN" "$bar" "$percent" "$RESET" "$operation"
}

advance_step() {
  local operation="$1"
  ((CURRENT_STEP++))
  draw_progress "$operation"
}

prompt_yes_no() {
  local question="$1"
  local reply

  while true; do
    read -r -p "$question [y/n]: " reply
    case "$reply" in
      [Yy]) return 0 ;;
      [Nn]) return 1 ;;
      *) printf 'Please answer y or n.\n' ;;
    esac
  done
}

resolve_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    readlink -f "$path" 2>/dev/null || printf '%s\n' "$path"
  else
    printf '%s\n' "$path"
  fi
}

is_ignored_file() {
  local rel="$1"
  local base="${rel##*/}"

  case "$base" in
    .DS_Store|*.swp|*.swo|*.tmp|*.bak|*~) return 0 ;;
  esac

  return 1
}

discover_managed_entries() {
  local package_dir package rel
  local -A package_seen=()

  while IFS= read -r -d '' package_dir; do
    package="$(basename "$package_dir")"
    while IFS= read -r -d '' rel; do
      if is_ignored_file "$rel"; then
        continue
      fi
      if [[ "$rel" != .* && "$rel" != */.* ]]; then
        continue
      fi
      MANAGED_ENTRIES+=("$package"$'\t'"$rel")
      package_seen["$package"]=1
    done < <(
      cd "$package_dir" && find . -type f -print0 | sed -z 's#^\./##'
    )
  done < <(
    find "$REPO_ROOT" -mindepth 1 -maxdepth 1 -type d \
      ! -name '.git' ! -name 'img' -print0
  )

  while IFS= read -r package; do
    PACKAGE_NAMES+=("$package")
  done < <(printf '%s\n' "${!package_seen[@]}" | sort)
}

load_manifest_if_present() {
  local kind col1 col2

  # The installer writes this manifest so uninstall can reliably detect whether
  # Stow or direct symlinks were used in this repository.
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    return 1
  fi

  while IFS=$'\t' read -r kind col1 col2; do
    case "$kind" in
      repo)
        if [[ "$col1" != "$REPO_ROOT" ]]; then
          return 1
        fi
        ;;
      method) INSTALL_METHOD="$col1" ;;
      package) INSTALLED_PACKAGES+=("$col1") ;;
      link) CANDIDATE_LINKS+=("$col1"$'\t'"$col2") ;;
      dir) CREATED_DIRS+=("$col1") ;;
    esac
  done <"$MANIFEST_PATH"

  return 0
}

detect_install_method() {
  local entry package rel src dest

  if load_manifest_if_present; then
    return 0
  fi

  INSTALL_METHOD="symlink"
  INSTALLED_PACKAGES=("${PACKAGE_NAMES[@]}")

  for entry in "${MANAGED_ENTRIES[@]}"; do
    package="${entry%%$'\t'*}"
    rel="${entry#*$'\t'}"
    src="$REPO_ROOT/$package/$rel"
    dest="$HOME/$rel"
    if [[ -L "$dest" ]] && [[ "$(resolve_path "$dest")" == "$(resolve_path "$src")" ]]; then
      CANDIDATE_LINKS+=("$dest"$'\t'"$src")
    fi
  done
}

collect_candidates_from_current_state() {
  local entry package rel src dest
  CANDIDATE_LINKS=()

  for entry in "${MANAGED_ENTRIES[@]}"; do
    package="${entry%%$'\t'*}"
    rel="${entry#*$'\t'}"
    src="$REPO_ROOT/$package/$rel"
    dest="$HOME/$rel"
    if [[ -L "$dest" ]] && [[ "$(resolve_path "$dest")" == "$(resolve_path "$src")" ]]; then
      CANDIDATE_LINKS+=("$dest"$'\t'"$src")
    fi
  done
}

collect_stow_preview() {
  local package line rel
  STOW_PREVIEW_ITEMS=()

  command -v stow >/dev/null 2>&1 || return 1

  for package in "${INSTALLED_PACKAGES[@]}"; do
    while IFS= read -r line; do
      case "$line" in
        "UNLINK: "*)
          rel="${line#UNLINK: }"
          rel="${rel%% ->*}"
          STOW_PREVIEW_ITEMS+=("$HOME/$rel")
          ;;
        "RMDIR: "*)
          rel="${line#RMDIR: }"
          STOW_PREVIEW_ITEMS+=("$HOME/$rel")
          ;;
      esac
    done < <(stow --dir "$REPO_ROOT" --target "$HOME" --delete --simulate -v 1 "$package" 2>/dev/null || true)
  done
}

show_removal_preview() {
  local link dest src item

  printf '\nUninstallation preview\n'
  printf 'Method detected: %s\n' "$INSTALL_METHOD"

  if (( ${#INSTALLED_PACKAGES[@]} > 0 )); then
    printf 'Packages in scope: %s\n' "${INSTALLED_PACKAGES[*]}"
  fi

  if [[ "$INSTALL_METHOD" == "stow" ]] && (( ${#STOW_PREVIEW_ITEMS[@]} > 0 )); then
    printf 'Items to remove (stow dry-run):\n'
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      printf '  %s\n' "$item"
    done < <(printf '%s\n' "${STOW_PREVIEW_ITEMS[@]}" | sort -u)
    return 0
  fi

  if (( ${#CANDIDATE_LINKS[@]} > 0 )); then
    printf 'Managed links to remove:\n'
    for link in "${CANDIDATE_LINKS[@]}"; do
      dest="${link%%$'\t'*}"
      src="${link#*$'\t'}"
      printf '  %s -> %s\n' "$dest" "$src"
    done
    return 0
  fi

  if [[ "$INSTALL_METHOD" == "stow" ]] && (( ${#INSTALLED_PACKAGES[@]} > 0 )); then
    printf 'No explicit link preview available, but these packages will be unstowed: %s\n' "${INSTALLED_PACKAGES[*]}"
    return 0
  fi

  printf 'No managed links found for this repository.\n'
  return 1
}

remove_with_stow() {
  local package

  if ! command -v stow >/dev/null 2>&1; then
    print_warn "stow is unavailable; falling back to direct managed-link removal."
    collect_candidates_from_current_state
    remove_with_symlinks
    return
  fi

  for package in "${INSTALLED_PACKAGES[@]}"; do
    advance_step "Unstowing package: $package"
    if ! stow --dir "$REPO_ROOT" --target "$HOME" --delete "$package"; then
      print_warn "Failed to unstow package: $package"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  done
}

remove_with_symlinks() {
  local link dest src

  for link in "${CANDIDATE_LINKS[@]}"; do
    dest="${link%%$'\t'*}"
    src="${link#*$'\t'}"

    advance_step "Removing link: $dest"
    if [[ -L "$dest" ]] && [[ "$(resolve_path "$dest")" == "$(resolve_path "$src")" ]]; then
      if ! rm -f "$dest"; then
        print_warn "Failed to remove link: $dest"
        ERROR_COUNT=$((ERROR_COUNT + 1))
      fi
    fi
  done
}

remove_empty_created_dirs() {
  local dir

  if (( ${#CREATED_DIRS[@]} == 0 )); then
    return
  fi

  while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue
    [[ "$dir" == "$HOME" ]] && continue
    [[ "$dir" == "/" ]] && continue
    [[ "$dir" != "$HOME/"* ]] && continue

    advance_step "Checking empty directory: $dir"
    if [[ -d "$dir" ]] && rmdir "$dir" 2>/dev/null; then
      :
    fi
  done < <(printf '%s\n' "${CREATED_DIRS[@]}" | awk 'NF' | sort -r)
}

cleanup_manifest_if_possible() {
  if (( ERROR_COUNT == 0 )) && [[ -f "$MANIFEST_PATH" ]]; then
    rm -f "$MANIFEST_PATH"
  fi
}

main() {
  if [[ ! -d "$REPO_ROOT" ]]; then
    print_error "Unable to detect repository root."
    exit 1
  fi

  discover_managed_entries
  detect_install_method

  if [[ "$INSTALL_METHOD" != "stow" && "$INSTALL_METHOD" != "symlink" ]]; then
    INSTALL_METHOD="symlink"
  fi

  if [[ "$INSTALL_METHOD" == "stow" ]]; then
    collect_stow_preview || true
    collect_candidates_from_current_state
  else
    collect_candidates_from_current_state
  fi

  if ! show_removal_preview; then
    exit 0
  fi

  if ! prompt_yes_no "Proceed with uninstall?"; then
    printf 'Uninstall cancelled.\n'
    exit 0
  fi

  if [[ "$INSTALL_METHOD" == "stow" ]]; then
    TOTAL_STEPS=$(( ${#INSTALLED_PACKAGES[@]} + ${#CREATED_DIRS[@]} + 2 ))
  else
    TOTAL_STEPS=$(( ${#CANDIDATE_LINKS[@]} + ${#CREATED_DIRS[@]} + 2 ))
  fi

  printf 'Dotfiles Uninstallation\n'
  draw_progress "Starting uninstallation"

  if [[ "$INSTALL_METHOD" == "stow" ]]; then
    remove_with_stow
  else
    remove_with_symlinks
  fi

  remove_empty_created_dirs
  advance_step "Cleaning installer state"
  cleanup_manifest_if_possible

  advance_step "Finalizing"
  printf '\n'

  if (( ERROR_COUNT == 0 )); then
    printf '%sUninstallation complete.%s\n' "$GREEN" "$RESET"
    exit 0
  fi

  printf '%sUninstallation finished with %d issue(s).%s\n' "$YELLOW" "$ERROR_COUNT" "$RESET"
  exit 1
}

main "$@"
