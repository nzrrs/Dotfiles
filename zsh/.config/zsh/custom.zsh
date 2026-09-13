# nvm (lazy load)
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# git lazy function 
gfast() {
    git add . &&
    git commit -m "Lazy to type an commit msg" &&
    git push
}

# Google search
google() {
    google-chrome "https://www.google.com/search?q=${(j:+:)@}" &
}

# GitHub repository search
gh() {
    google-chrome "https://github.com/search?q=${(j:+:)@}&type=repositories" &
}

# YouTube search
yt() {
    google-chrome "https://www.youtube.com/results?search_query=${(j:+:)@}" &
}

# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# syntax highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# fzf
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

# startup banner
fastfetch
