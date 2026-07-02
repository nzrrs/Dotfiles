# Neovim Keymaps Cheat Sheet

A quick reference for custom Neovim keybindings.


# Table of Contents

- [Leader Key](#leader-key)
- [General](#general)
- [Files](#files)
- [Buffers](#buffers)
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

---

# Leader Key

| Key | Value |
|------|-------|
| Leader | `<Space>` |

---

# General

| Key | Action |
|------|--------|
| `Esc` | Clear search highlights |
| `Ctrl+s` | Save file |
| `Ctrl+q` | Quit |
| `<leader>sn` | Save without autocommands |
| `<leader>lw` | Toggle line wrapping |

---

# Files

| Key | Action |
|------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>b` | New buffer |
| `<leader>x` | Close current buffer |

---

# Buffers

| Key | Action |
|------|--------|
| `<leader>+` | Increment number |
| `<leader>-` | Decrement number |

---

# Windows

## Splits

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

---

# Tabs

| Key | Action |
|------|--------|
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn` | Next tab |
| `<leader>tp` | Previous tab |

---

# Navigation

| Key | Action |
|------|--------|
| `Ctrl+d` | Half-page down and center |
| `Ctrl+u` | Half-page up and center |
| `n` | Next search result and center |
| `N` | Previous search result and center |

---

# Editing

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

---

# Clipboard

| Key | Action |
|------|--------|
| `<leader>y` | Copy selection to system clipboard |
| `<leader>Y` | Copy current line to system clipboard |

---

# Diagnostics

| Key | Action |
|------|--------|
| `<leader>do` | Toggle diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic popup |
| `<leader>q` | Open diagnostics list |

---

# Sessions

| Key | Action |
|------|--------|
| `<leader>ss` | Save session |
| `<leader>sl` | Load session |

---

# Neo-tree Global

| Key | Action |
|------|--------|
| `<leader>e` | Toggle left file explorer |
| `<leader>w` | Toggle floating file explorer |
| `<leader>ngs` | Open Git Status window |
| `\` | Reveal current file |

---

# Neo-tree Navigation

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

---# Neovim Keymaps Cheat Sheet

A quick reference for custom Neovim keybindings.

---

# Table of Contents

- [Leader Key](#leader-key)
- [General](#general)
- [Files](#files)
- [Buffers](#buffers)
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

---

# Leader Key

| Key | Value |
|------|-------|
| Leader | `<Space>` |

---

# General

| Key | Action |
|------|--------|
| `Esc` | Clear search highlights |
| `Ctrl+s` | Save file |
| `Ctrl+q` | Quit |
| `<leader>sn` | Save without autocommands |
| `<leader>lw` | Toggle line wrapping |

---

# Files

| Key | Action |
|------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>b` | New buffer |
| `<leader>x` | Close current buffer |

---

# Buffers

| Key | Action |
|------|--------|
| `<leader>+` | Increment number |
| `<leader>-` | Decrement number |

---

# Windows

## Splits

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

---

# Tabs

| Key | Action |
|------|--------|
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn` | Next tab |
| `<leader>tp` | Previous tab |

---

# Navigation

| Key | Action |
|------|--------|
| `Ctrl+d` | Half-page down and center |
| `Ctrl+u` | Half-page up and center |
| `n` | Next search result and center |
| `N` | Previous search result and center |

---

# Editing

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

---

# Clipboard

| Key | Action |
|------|--------|
| `<leader>y` | Copy selection to system clipboard |
| `<leader>Y` | Copy current line to system clipboard |

---

# Diagnostics

| Key | Action |
|------|--------|
| `<leader>do` | Toggle diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic popup |
| `<leader>q` | Open diagnostics list |

---

# Sessions

| Key | Action |
|------|--------|
| `<leader>ss` | Save session |
| `<leader>sl` | Load session |

---

# Neo-tree Global

| Key | Action |
|------|--------|
| `<leader>e` | Toggle left file explorer |
| `<leader>w` | Toggle floating file explorer |
| `<leader>ngs` | Open Git Status window |
| `\` | Reveal current file |

---

# Neo-tree Navigation

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

---

# Neo-tree File Operations

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

---

# Neo-tree Search & Sorting

## Navigation

| Key | Action |
|------|--------|
| `Backspace` | Parent directory |
| `.` | Set current directory as root |
| `H` | Toggle hidden files |

## Search

| Key | Action |
|------|--------|
| `/` | Fuzzy finder |
| `D` | Fuzzy directory finder |
| `#` | Fuzzy sorter |
| `f` | Filter |
| `Ctrl+x` | Clear filter |

## Git Navigation

| Key | Action |
|------|--------|
| `[g` | Previous modified file |
| `]g` | Next modified file |

## Sorting

| Key | Action |
|------|--------|
| `oc` | Sort by created date |
| `od` | Sort by diagnostics |
| `og` | Sort by Git status |
| `om` | Sort by modified date |
| `on` | Sort by name |
| `os` | Sort by size |
| `ot` | Sort by type |

---

# Neo-tree Git Status

| Key | Action |
|------|--------|
| `A` | Stage all |
| `ga` | Stage file |
| `gu` | Unstage file |
| `gr` | Revert file |
| `gc` | Commit |
| `gp` | Push |
| `gg` | Commit and push |

# Neo-tree File Operations

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

---

# Neo-tree Search & Sorting

## Navigation

| Key | Action |
|------|--------|
| `Backspace` | Parent directory |
| `.` | Set current directory as root |
| `H` | Toggle hidden files |

## Search

| Key | Action |
|------|--------|
| `/` | Fuzzy finder |
| `D` | Fuzzy directory finder |
| `#` | Fuzzy sorter |
| `f` | Filter |
| `Ctrl+x` | Clear filter |

## Git Navigation

| Key | Action |
|------|--------|
| `[g` | Previous modified file |
| `]g` | Next modified file |

## Sorting

| Key | Action |
|------|--------|
| `oc` | Sort by created date |
| `od` | Sort by diagnostics |
| `og` | Sort by Git status |
| `om` | Sort by modified date |
| `on` | Sort by name |
| `os` | Sort by size |
| `ot` | Sort by type |

---

# Neo-tree Git Status

| Key | Action |
|------|--------|
| `A` | Stage all |
| `ga` | Stage file |
| `gu` | Unstage file |
| `gr` | Revert file |
| `gc` | Commit |
| `gp` | Push |
| `gg` | Commit and push |
