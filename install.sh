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

TOTAL_STEPS=100
CURRENT_STEP=0
ERROR_COUNT=0
APT_UPDATED=0

LINK_METHOD=""
PACKAGE_MANAGER=""
SUDO_CMD=""

declare -a MANAGED_ENTRIES=()       # "package<TAB>relative_file"
declare -a PACKAGE_NAMES=()
declare -a REQUIRED_DEPENDENCIES=() # "cmd:pkg_name"
declare -a MISSING_DEPENDENCIES=()
declare -a CONFLICTS=()             # "package<TAB>rel<TAB>dest<TAB>src<TAB>type"
declare -a CREATED_DIRS=()
declare -a MANAGED_LINKS=()         # "dest<TAB>src"
declare -a INSTALLED_PACKAGES=()

declare -A SKIPPED_KEYS=()          # key "package<TAB>rel"
declare -A SKIPPED_PACKAGES=()      # key package -> 1
CONFLICT_ACTION_FOR_ALL=""

print_error() {
  printf '\n%sError:%s %s\n' "$RED" "$RESET" "$*" >&2
}

print_warn() {
  printf '\n%sWarning:%s %s\n' "$YELLOW" "$RESET" "$*"
}

print_info() {
  printf '\n%s\n' "$*"
}

draw_progress() {
  local operation="$1"
  local cols bar_width fill empty percent bar

  cols="$(tput cols 2>/dev/null || printf '80\n')"
  bar_width=$((cols - 45))
  (( bar_width < 10 )) && bar_width=10

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

set_progress_percent() {
  local percent="$1"
  local operation="$2"
  if (( percent < 0 )); then
    percent=0
  elif (( percent > 100 )); then
    percent=100
  fi
  CURRENT_STEP="$percent"
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

prompt_conflict_action() {
  local dest="$1"
  local type="$2"
  local reply

  printf '\nConflict: %s (%s)\n' "$dest" "$type" >&2
  printf '  [b] Backup and continue\n' >&2
  printf '  [s] Skip this item\n' >&2
  printf '  [r] Replace\n' >&2
  printf '  [c] Cancel installation\n' >&2

  while true; do
    read -r -p 'Choose [b/s/r/c]: ' reply
    case "$reply" in
      [Bb]) printf 'backup\n'; return 0 ;;
      [Ss]) printf 'skip\n'; return 0 ;;
      [Rr]) printf 'replace\n'; return 0 ;;
      [Cc]) printf 'cancel\n'; return 0 ;;
      *) printf 'Please choose b, s, r, or c.\n' ;;
    esac
  done
}

prompt_conflict_action_for_all() {
  local total="$1"
  local reply

  printf '\n%d conflict(s) detected.\n' "$total" >&2
  printf 'Choose one action to apply to all conflicts:\n' >&2
  printf '  [b] Backup all and continue\n' >&2
  printf '  [s] Skip all conflicting items\n' >&2
  printf '  [r] Replace all conflicts\n' >&2
  printf '  [c] Cancel installation\n' >&2

  while true; do
    read -r -p 'Choose [b/s/r/c]: ' reply
    case "$reply" in
      [Bb]) printf 'backup\n'; return 0 ;;
      [Ss]) printf 'skip\n'; return 0 ;;
      [Rr]) printf 'replace\n'; return 0 ;;
      [Cc]) printf 'cancel\n'; return 0 ;;
      *) printf 'Please choose b, s, r, or c.\n' ;;
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

safe_backup_path() {
  local original="$1"
  local candidate="${original}.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
  local i=1

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    candidate="${original}.dotfiles-backup-$(date +%Y%m%d%H%M%S)-$i"
    i=$((i + 1))
  done
  printf '%s\n' "$candidate"
}

discover_managed_entries() {
  local package_dir package rel
  local -A package_seen=()

  while IFS= read -r -d '' package_dir; do
    package="$(basename "$package_dir")"
    while IFS= read -r -d '' rel; do
      is_ignored_file "$rel" && continue
      # Dotfiles in this repository are intentionally stored under paths like
      # ".zshrc" or ".config/..."; non-dot paths are not treated as managed configs.
      [[ "$rel" != .* && "$rel" != */.* ]] && continue
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

register_base_dependencies() {
  local pkg
  local -A dep_map=(
    ["fastfetch"]="fastfetch:fastfetch"
    ["ghostty"]="ghostty:ghostty"
    ["nvim"]="nvim:neovim"
    ["starship"]="starship:starship"
    ["tmux"]="tmux:tmux"
    ["vim"]="vim:vim"
    ["yazi"]="yazi:yazi"
    ["zsh"]="zsh:zsh"
  )

  REQUIRED_DEPENDENCIES=()
  for pkg in "${PACKAGE_NAMES[@]}"; do
    [[ -n "${dep_map[$pkg]:-}" ]] && REQUIRED_DEPENDENCIES+=("${dep_map[$pkg]}")
  done
}

detect_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PACKAGE_MANAGER="dnf"
  elif command -v yum >/dev/null 2>&1; then
    PACKAGE_MANAGER="yum"
  elif command -v pacman >/dev/null 2>&1; then
    PACKAGE_MANAGER="pacman"
  elif command -v zypper >/dev/null 2>&1; then
    PACKAGE_MANAGER="zypper"
  elif command -v apk >/dev/null 2>&1; then
    PACKAGE_MANAGER="apk"
  elif command -v xbps-install >/dev/null 2>&1; then
    PACKAGE_MANAGER="xbps"
  else
    PACKAGE_MANAGER=""
  fi

  if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO_CMD="sudo"
  else
    SUDO_CMD=""
  fi
}

install_dependency() {
  local dep_pkg="$1"

  if [[ -z "$PACKAGE_MANAGER" ]]; then
    print_warn "No supported package manager detected; cannot auto-install $dep_pkg."
    return 1
  fi

  if [[ -z "$SUDO_CMD" && "$(id -u)" -ne 0 ]]; then
    print_warn "sudo is not available; cannot auto-install $dep_pkg."
    return 1
  fi

  case "$PACKAGE_MANAGER" in
    apt)
      if (( APT_UPDATED == 0 )); then
        $SUDO_CMD apt-get update -y || return 1
        APT_UPDATED=1
      fi
      $SUDO_CMD apt-get install -y "$dep_pkg"
      ;;
    dnf) $SUDO_CMD dnf install -y "$dep_pkg" ;;
    yum) $SUDO_CMD yum install -y "$dep_pkg" ;;
    pacman) $SUDO_CMD pacman -Sy --needed --noconfirm "$dep_pkg" ;;
    zypper) $SUDO_CMD zypper --non-interactive install "$dep_pkg" ;;
    apk) $SUDO_CMD apk add "$dep_pkg" ;;
    xbps) $SUDO_CMD xbps-install -Sy "$dep_pkg" ;;
    *) return 1 ;;
  esac
}

check_dependencies() {
  local spec dep_cmd
  MISSING_DEPENDENCIES=()
  for spec in "${REQUIRED_DEPENDENCIES[@]}"; do
    dep_cmd="${spec%%:*}"
    advance_step "Checking dependency: $dep_cmd"
    if ! command -v "$dep_cmd" >/dev/null 2>&1; then
      MISSING_DEPENDENCIES+=("$spec")
    fi
  done
}

handle_missing_dependencies() {
  local spec dep_cmd dep_pkg
  for spec in "${MISSING_DEPENDENCIES[@]}"; do
    dep_cmd="${spec%%:*}"
    dep_pkg="${spec##*:}"
    print_warn "Missing dependency: $dep_cmd"
    if prompt_yes_no "Install $dep_pkg now?"; then
      advance_step "Installing dependency: $dep_pkg"
      if ! install_dependency "$dep_pkg"; then
        print_warn "Install failed for $dep_pkg; continuing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
      fi
    else
      advance_step "Skipping dependency: $dep_pkg"
    fi
  done
}

choose_link_method() {
  local choice
  printf '\nHow would you like dotfiles to be linked?\n'
  printf '  1) GNU Stow\n'
  printf '  2) Normal symlinks\n'
  while true; do
    read -r -p 'Choose an option [1/2]: ' choice
    case "$choice" in
      1) LINK_METHOD="stow"; return 0 ;;
      2) LINK_METHOD="symlink"; return 0 ;;
      *) printf 'Please choose 1 or 2.\n' ;;
    esac
  done
}

ensure_stow_if_selected() {
  if [[ "$LINK_METHOD" != "stow" ]]; then
    return 0
  fi
  if command -v stow >/dev/null 2>&1; then
    return 0
  fi

  print_warn "GNU Stow is required for option 1 and is currently missing."
  if prompt_yes_no "Install stow now?"; then
    advance_step "Installing dependency: stow"
    if install_dependency "stow" && command -v stow >/dev/null 2>&1; then
      return 0
    fi
    print_warn "stow installation failed; switching to normal symlinks."
    LINK_METHOD="symlink"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    return 0
  fi

  print_warn "stow install skipped; switching to normal symlinks."
  LINK_METHOD="symlink"
}

scan_conflicts() {
  local entry package rel src dest dest_target src_target

  CONFLICTS=()
  for entry in "${MANAGED_ENTRIES[@]}"; do
    package="${entry%%$'\t'*}"
    rel="${entry#*$'\t'}"
    src="$REPO_ROOT/$package/$rel"
    dest="$HOME/$rel"

    advance_step "Scanning conflicts: $rel"

    if [[ -L "$dest" ]]; then
      dest_target="$(resolve_path "$dest")"
      src_target="$(resolve_path "$src")"
      if [[ "$dest_target" != "$src_target" ]]; then
        CONFLICTS+=("$package"$'\t'"$rel"$'\t'"$dest"$'\t'"$src"$'\t'"symlink")
      fi
    elif [[ -e "$dest" ]]; then
      CONFLICTS+=("$package"$'\t'"$rel"$'\t'"$dest"$'\t'"$src"$'\t'"path")
    fi
  done
}

show_conflicts() {
  local item package rel dest type
  if (( ${#CONFLICTS[@]} == 0 )); then
    print_info "No conflicts found."
    return
  fi

  printf '\nConflicts detected:\n'
  for item in "${CONFLICTS[@]}"; do
    package="${item%%$'\t'*}"
    rel="${item#*$'\t'}"
    rel="${rel%%$'\t'*}"
    dest="${item#*$'\t'*$'\t'}"
    dest="${dest%%$'\t'*}"
    type="${item##*$'\t'}"
    printf '  - [%s] %s (%s)\n' "$package" "$dest" "$type"
  done
}

resolve_conflicts() {
  local item package rel key dest src type action backup
  if (( ${#CONFLICTS[@]} > 0 )); then
    action="$(prompt_conflict_action_for_all "${#CONFLICTS[@]}")"
    CONFLICT_ACTION_FOR_ALL="$action"
    if [[ "$action" == "cancel" ]]; then
      print_warn "Installation cancelled by user."
      exit 1
    fi
  fi

  for item in "${CONFLICTS[@]}"; do
    package="${item%%$'\t'*}"
    rel="${item#*$'\t'}"; rel="${rel%%$'\t'*}"
    dest="${item#*$'\t'*$'\t'}"; dest="${dest%%$'\t'*}"
    src="${item#*$'\t'*$'\t'*$'\t'}"; src="${src%%$'\t'*}"
    type="${item##*$'\t'}"
    key="$package"$'\t'"$rel"
    advance_step "Resolving conflict: $rel"
    action="$CONFLICT_ACTION_FOR_ALL"

    case "$action" in
      backup)
        backup="$(safe_backup_path "$dest")"
        if mv "$dest" "$backup"; then
          print_info "Backed up: $dest -> $backup"
        else
          print_error "Backup failed for $dest"
          return 1
        fi
        ;;
      skip)
        SKIPPED_KEYS["$key"]=1
        if [[ "$LINK_METHOD" == "stow" ]]; then
          SKIPPED_PACKAGES["$package"]=1
        fi
        ;;
      replace)
        if [[ -L "$dest" ]]; then
          rm -f "$dest" || return 1
        elif [[ -e "$dest" ]]; then
          backup="$(safe_backup_path "$dest")"
          mv "$dest" "$backup" || return 1
          print_info "Replaced by backing up existing path: $backup"
        fi
        ;;
      cancel)
        print_warn "Installation cancelled by user."
        exit 1
        ;;
      *)
        print_error "Unknown conflict action: $action"
        return 1
        ;;
    esac

    # src is intentionally touched so shellcheck does not warn in stricter setups.
    [[ -n "$src" ]] || true
  done
}

prepare_required_directories() {
  local entry package rel key dest dir
  local -A dirs=()

  if [[ "$LINK_METHOD" != "symlink" ]]; then
    return
  fi

  for entry in "${MANAGED_ENTRIES[@]}"; do
    package="${entry%%$'\t'*}"
    rel="${entry#*$'\t'}"
    key="$package"$'\t'"$rel"
    [[ -n "${SKIPPED_KEYS[$key]:-}" ]] && continue

    dest="$HOME/$rel"
    dir="$(dirname "$dest")"
    dirs["$dir"]=1
  done

  while IFS= read -r dir; do
    advance_step "Ensuring directory exists: $dir"
    [[ -d "$dir" ]] && continue
    if mkdir -p "$dir"; then
      CREATED_DIRS+=("$dir")
    else
      print_error "Failed to create directory: $dir"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  done < <(printf '%s\n' "${!dirs[@]}" | sort)
}

record_managed_link() {
  local dest="$1"
  local src="$2"
  MANAGED_LINKS+=("$dest"$'\t'"$src")
}

install_with_symlinks() {
  local entry package rel key src dest
  for entry in "${MANAGED_ENTRIES[@]}"; do
    package="${entry%%$'\t'*}"
    rel="${entry#*$'\t'}"
    key="$package"$'\t'"$rel"
    [[ -n "${SKIPPED_KEYS[$key]:-}" ]] && continue

    src="$REPO_ROOT/$package/$rel"
    dest="$HOME/$rel"
    advance_step "Linking: $rel"

    if [[ -L "$dest" ]] && [[ "$(resolve_path "$dest")" == "$(resolve_path "$src")" ]]; then
      record_managed_link "$dest" "$src"
      continue
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
      print_warn "Skipped (still conflicting): $dest"
      ERROR_COUNT=$((ERROR_COUNT + 1))
      continue
    fi

    if ln -s "$src" "$dest"; then
      record_managed_link "$dest" "$src"
    else
      print_error "Failed to create symlink: $dest"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  done
}

install_with_stow() {
  local package entry rel src dest key
  for package in "${PACKAGE_NAMES[@]}"; do
    if [[ -n "${SKIPPED_PACKAGES[$package]:-}" ]]; then
      print_warn "Skipping package due to user-skipped conflicts: $package"
      continue
    fi

    advance_step "Stowing package: $package"
    if stow --dir "$REPO_ROOT" --target "$HOME" "$package"; then
      INSTALLED_PACKAGES+=("$package")
      for entry in "${MANAGED_ENTRIES[@]}"; do
        [[ "${entry%%$'\t'*}" != "$package" ]] && continue
        rel="${entry#*$'\t'}"
        key="$package"$'\t'"$rel"
        [[ -n "${SKIPPED_KEYS[$key]:-}" ]] && continue
        src="$REPO_ROOT/$package/$rel"
        dest="$HOME/$rel"
        if [[ "$(resolve_path "$dest")" == "$(resolve_path "$src")" ]]; then
          record_managed_link "$dest" "$src"
        fi
      done
    else
      print_error "stow failed for package: $package"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  done
}

write_manifest() {
  local method="$1"
  local package link dir

  mkdir -p "$STATE_DIR"
  : >"$MANIFEST_PATH"

  printf 'repo\t%s\n' "$REPO_ROOT" >>"$MANIFEST_PATH"
  printf 'method\t%s\n' "$method" >>"$MANIFEST_PATH"

  for package in "${INSTALLED_PACKAGES[@]}"; do
    printf 'package\t%s\n' "$package" >>"$MANIFEST_PATH"
  done
  for link in "${MANAGED_LINKS[@]}"; do
    printf 'link\t%s\n' "$link" >>"$MANIFEST_PATH"
  done
  for dir in "${CREATED_DIRS[@]}"; do
    printf 'dir\t%s\n' "$dir" >>"$MANIFEST_PATH"
  done
}

main() {
  if [[ ! -d "$REPO_ROOT" ]]; then
    print_error "Unable to detect repository root."
    exit 1
  fi

  printf 'Dotfiles Installation\n'
  set_progress_percent 0 "Detecting repository"

  discover_managed_entries
  if (( ${#PACKAGE_NAMES[@]} == 0 )); then
    print_error "No installable dotfile packages were discovered."
    exit 1
  fi

  detect_package_manager
  register_base_dependencies

  set_progress_percent 10 "Checking dependencies"
  check_dependencies

  set_progress_percent 20 "Resolving missing dependencies"
  handle_missing_dependencies

  set_progress_percent 30 "Choosing link method"
  choose_link_method
  ensure_stow_if_selected

  set_progress_percent 40 "Scanning for conflicts"
  scan_conflicts

  set_progress_percent 50 "Showing detected conflicts"
  show_conflicts

  set_progress_percent 60 "Resolving conflicts"
  resolve_conflicts || exit 1

  set_progress_percent 70 "Creating required directories"
  prepare_required_directories

  set_progress_percent 80 "Installing configurations"
  if [[ "$LINK_METHOD" == "stow" ]]; then
    install_with_stow
  else
    INSTALLED_PACKAGES=("${PACKAGE_NAMES[@]}")
    install_with_symlinks
  fi

  set_progress_percent 95 "Writing installer state"
  write_manifest "$LINK_METHOD"

  set_progress_percent 100 "Installation complete"
  printf '\n'

  if (( ERROR_COUNT == 0 )); then
    printf '%sInstallation complete.%s\n' "$GREEN" "$RESET"
    exit 0
  fi

  printf '%sInstallation completed with %d issue(s).%s\n' "$YELLOW" "$ERROR_COUNT" "$RESET"
  exit 1
}

main "$@"
