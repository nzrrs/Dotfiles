#clipboard
alias c='xclip -selection clipboard'
alias p='xclip -selection clipboard -o'
alias cf='xclip -selection clipboard <'
alias cwd='pwd | xclip -selection clipboard'

#mini(1337)
alias mini='~/mini-moulinette/mini-moul.sh'

#system
alias shutdown='sudo shutdown now'
alias reboot='sudo reboot'
alias sleep='sudo pm-suspend'
alias logout='gnome-session-quit --logout'

# git
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gpo='git push origin'
alias gplo='git pull origin'
alias gsw='git switch'
alias gswc='git switch -c'
alias grao='git remote add origin'
alias grmo='git remote rm origin'
alias grv='git remote -v'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate -n 20'
alias gd='git diff'
alias gds='git diff --staged'


# eza
alias ls="eza --all --icons=always"
alias ll="eza -la --icons=always"
alias lt="eza --tree --icons=always"

# zoxide
alias cd='z'
