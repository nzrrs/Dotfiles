export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_MAGIC_FUNCTIONS="true"

plugins=(git zsh-autosuggestions docker docker-compose)
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

source $ZSH/oh-my-zsh.sh

source ~/aliases.zsh
source ~/custom.zsh

eval "$(starship init zsh)"
