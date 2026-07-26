# Dotfiles Shortcuts Cheat Sheet

Quick reference for all custom keybindings & aliases across tools :).

---

## Table of Contents
- [Tmux](#tmux)
- [Zsh](#zsh)
- [Neovim](#neovim)
  - [Leader Key](#leader-key)
  - [General](#general)
  - [Files](#files)
  - [Buffers](#buffers)
  - [Yazi Integration](#yazi-integration)
  - [Windows](#windows)
  - [Tabs](#tabs)
  - [Navigation](#navigation)
  - [Editing](#editing)
  - [Clipboard](#clipboard)
  - [Diagnostics](#diagnostics)
  - [Sessions](#sessions)
  - [Neo-tree Global](#neo-tree-global)
  - [Neo-tree Navigation](#neo-tree-navigation)
  - [Neo-tree File Operations](#neo-tree-file-operations)
  - [Neo-tree Search & Sorting](#neo-tree-search--sorting)
  - [Neo-tree Git Status](#neo-tree-git-status)
- [Yazi](#yazi)

---

# Tmux

| Key | Action |
|------|--------|
| `Ctrl+Space` | Prefix key |
| `prefix + \|` | Split pane horizontally |
| `prefix + -` | Split pane vertically |
| `prefix + r` | Reload tmux config |
| `Alt+h` | Move to left pane |
| `Alt+j` | Move to pane below |
| `Alt+k` | Move to pane above |
| `Alt+l` | Move to right pane |

**Notes:** Mouse mode is enabled. Window auto-rename is disabled.

## Default Keybinds (unchanged, prefix = Ctrl+Space)

| Key | Action |
|------|--------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + 0-9` | Switch to window number |
| `prefix + w` | List windows |
| `prefix + x` | Kill current pane |
| `prefix + z` | Zoom/unzoom current pane |
| `prefix + d` | Detach from session |
| `prefix + [` | Enter copy mode |
| `prefix + ]` | Paste buffer |
| `prefix + t` | Show clock |
| `prefix + :` | Command prompt |
| `prefix + ?` | List all keybindings |
| `prefix + q` | Show pane numbers |
| `prefix + {` | Swap pane left |
| `prefix + }` | Swap pane right |

---

# Zsh

## Clipboard

| Alias | Command |
|-------|---------|
| `c` | `xclip -selection clipboard` |
| `p` | `xclip -selection clipboard -o` |
| `cf` | `xclip -selection clipboard <` |
| `cwd` | `pwd \| xclip -selection clipboard` |

## System

| Alias | Command |
|-------|---------|
| `shutdown` | `sudo shutdown now` |
| `reboot` | `sudo reboot` |
| `sleep` | `sudo pm-suspend` |
| `logout` | `gnome-session-quit --logout` |

## Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gcm` | `git commit -m` |
| `gca` | `git commit --amend` |
| `gpo` | `git push origin` |
| `gplo` | `git pull origin` |
| `gsw` | `git switch` |
| `gswc` | `git switch -c` |
| `grao` | `git remote add origin` |
| `grmo` | `git remote rm origin` |
| `grv` | `git remote -v` |
| `gb` | `git branch` |
| `gl` | `git log --oneline --graph --decorate -n 20` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |

## Files (eza)

| Alias | Command |
|-------|---------|
| `ls` | `eza --all --icons=always` |
| `ll` | `eza -la --icons=always` |
| `lt` | `eza --tree --icons=always` |

## Fuzzy Finder (fzf)

| Key | Action |
|-----|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files, insert path |
| `Alt+C` | Fuzzy find directory, cd into it |

## Navigation (zoxide)

| Command | Action |
|---------|--------|
| `z <name>` | Jump to best-matching visited directory |
| `zi` | Interactive fuzzy directory select |

## Misc

| Alias | Command |
|-------|---------|
| `mini` | `~/mini-moulinette/mini-moul.sh` |

## Default Zsh Line Editing (unchanged)

| Key | Action |
|------|--------|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+U` | Delete whole line before cursor |
| `Ctrl+K` | Delete from cursor to end of line |
| `Ctrl+L` | Clear screen |
| `Ctrl+R` | Reverse search history (overridden by fzf, see above) |
| `Alt+.` | Insert last argument of previous command |
| `Tab` | Autocomplete |

---

# Neovim

## Leader Key

| Key | Value |
|------|-------|
| Leader | `<Space>` |

## General

| Key | Action |
|------|--------|
| `Esc` | Clear search highlights |
| `Ctrl+s` | Save file |
| `Ctrl+q` | Quit |
| `<leader>sn` | Save without autocommands |
| `<leader>lw` | Toggle line wrapping |

## Files

| Key | Action |
|------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>b` | New buffer |
| `<leader>x` | Close current buffer |
| `Ctrl+i` | Restore jump forward |
| `<leader>bp` | Toggle buffer pin |

## Buffers

| Key | Action |
|------|--------|
| `<leader>+` | Increment number |
| `<leader>-` | Decrement number |

## Windows

### Splits

| Key | Action |
|------|--------|
| `<leader>v` | Vertical split |
| `<leader>h` | Horizontal split |
| `<leader>se` | Equalize split sizes |
| `<leader>xs` | Close split |

### Move Between Splits

| Key | Action |
|------|--------|
| `Ctrl+h` | Left window |
| `Ctrl+j` | Bottom window |
| `Ctrl+k` | Top window |
| `Ctrl+l` | Right window |

### Resize Splits

| Key | Action |
|------|--------|
| `↑` | Increase height |
| `↓` | Decrease height |
| `←` | Decrease width |
| `→` | Increase width |

## Tabs

| Key | Action |
|------|--------|
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn` | Next tab |
| `<leader>tp` | Previous tab |

## Navigation

| Key | Action |
|------|--------|
| `Ctrl+d` | Half-page down and center |
| `Ctrl+u` | Half-page up and center |
| `n` | Next search result and center |
| `N` | Previous search result and center |

## Editing

| Key | Action |
|------|--------|
| `x` | Delete character without yanking |
| `jk` | Exit Insert mode |
| `kj` | Exit Insert mode |
| `<` | Indent left and keep selection |
| `>` | Indent right and keep selection |
| `Alt+j` | Move selected lines down |
| `Alt+k` | Move selected lines up |
| `p` (Visual) | Paste without replacing yank register |
| `<leader>j` | Replace word under cursor |

## Clipboard

| Key | Action |
|------|--------|
| `<leader>y` | Copy selection to system clipboard |
| `<leader>Y` | Copy current line to system clipboard |

## Diagnostics

| Key | Action |
|------|--------|
| `<leader>do` | Toggle diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic popup |
| `<leader>q` | Open diagnostics list |

## Sessions

| Key | Action |
|------|--------|
| `<leader>ss` | Save session |
| `<leader>sl` | Load session |

## Yazi Integration

| Key | Action |
|------|--------|
| `<leader>ya` | Open Yazi file manager |

## Neo-tree Global

| Key | Action |
|------|--------|
| `<leader>e` | Toggle left file explorer |
| `<leader>w` | Toggle floating file explorer |
| `<leader>ngs` | Open Git Status window |
| `\` | Reveal current file |

## Neo-tree Navigation

| Key | Action |
|------|--------|
| `Enter` | Open |
| `l` | Open |
| `P` | Preview file |
| `S` | Horizontal split |
| `s` | Vertical split |
| `t` | Open in new tab |
| `w` | Open with window picker |
| `Esc` | Cancel preview |
| `q` | Close Neo-tree |
| `C` | Close directory |
| `z` | Collapse all directories |
| `Space` | Expand/Collapse directory |
| `<` | Previous source |
| `>` | Next source |
| `i` | File details |
| `?` | Help |

## Neo-tree File Operations

| Key | Action |
|------|--------|
| `a` | Create file |
| `A` | Create directory |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `y` | Copy to clipboard |
| `x` | Cut |
| `p` | Paste |
| `R` | Refresh |

## Neo-tree Search & Sorting

### Navigation

| Key | Action |
|------|--------|
| `Backspace` | Parent directory |
| `.` | Set current directory as root |
| `H` | Toggle hidden files |

### Search

| Key | Action |
|------|--------|
| `/` | Fuzzy finder |
| `D` | Fuzzy directory finder |
| `#` | Fuzzy sorter |
| `f` | Filter |
| `Ctrl+x` | Clear filter |

### Git Navigation

| Key | Action |
|------|--------|
| `[g` | Previous modified file |
| `]g` | Next modified file |

### Sorting

| Key | Action |
|------|--------|
| `oc` | Sort by created date |
| `od` | Sort by diagnostics |
| `og` | Sort by Git status |
| `om` | Sort by modified date |
| `on` | Sort by name |
| `os` | Sort by size |
| `ot` | Sort by type |

## Neo-tree Git Status

| Key | Action |
|------|--------|
| `A` | Stage all |
| `ga` | Stage file |
| `gu` | Unstage file |
| `gr` | Revert file |
| `gc` | Commit |
| `gp` | Push |
| `gg` | Commit and push |

---

# Yazi

*Default keybindings — update this section if you customize `yazi.toml` / `keymap.toml`.*

| Key | Action |
|------|--------|
| `h` / `←` | Go to parent directory |
| `l` / `→` / `Enter` | Open file / enter directory |
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `Space` | Toggle selection |
| `v` | Enter visual mode (select range) |
| `y` | Yank (copy) |
| `x` | Cut |
| `p` | Paste |
| `d` | Delete (trash) |
| `a` | Create file/directory |
| `r` | Rename |
| `/` | Search |
| `q` | Quit |
| `Tab` | Toggle preview pane |
| `.` | Toggle hidden files |
