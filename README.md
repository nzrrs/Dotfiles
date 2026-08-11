# Dotfiles

My config files for maintaining a consistent dev environment across machines.

<img width="1912" height="1031" alt="image" src="https://github.com/user-attachments/assets/57dc3125-af8f-441c-a23a-65a4f59529cc" />

## Essential Tools
- **Editor**: [NeoVim](https://neovim.io/)
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki)
- **Main Terminal**: [Ghostty](https://ghostty.org/)
- **Shell**: [Zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/)
- **Shell Prompt**: [Starship](https://starship.rs/)
- **File Manager**: [Yazi](https://yazi-rs.github.io/)
- **Fuzzy Finder**: [fzf](https://github.com/junegunn/fzf)
- **Smart `cd`**: [zoxide](https://github.com/ajeetdsouza/zoxide)
- **File Listing**: [eza](https://github.com/eza-community/eza)
- **System Info**: [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- **Dotfiles Manager**: [GNU Stow](https://www.gnu.org/software/stow/)

## Setup

Clone the repository:

```bash
git clone <your-repository-url>
cd Dotfiles
```

Run the installer from the repo root and follow the on-screen prompts:

```bash
./install.sh
```

The installer checks dependencies, detects conflicts, and sets up the dotfiles using GNU Stow or normal symlinks.

> [!NOTE]
   The installer never modifies the files inside the repository. Any required backups are stored outside the repository.

## Uninstalling

To remove the dotfiles installed by the script:

```bash
./uninstall.sh
```

The uninstaller removes the symlinks created by the installation and preserves the original files in the repository.

> [!IMPORTANT]
> - Uninstalling never deletes or modifies files inside the repository.
> - Run the installer from the repository root and follow the prompts before manually changing any symlinks.
