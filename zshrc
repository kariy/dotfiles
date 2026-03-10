[ -f ~/z.sh ] && . ~/z.sh
fpath=(~/.zsh $fpath)


## rust --------------  

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"


## go ---------------- 

export PATH="$PATH:$HOME/go/bin"


## nvm --------------- 

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


## starship --------- 

if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi


## zoxide ----------- 

eval "$(zoxide init zsh)"


## git --------------

zstyle ':completion:*:*:git:*' script ~/.git-completion.bash


## bun -------------- 

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


## fzf --------------

export FZF_DEFAULT_OPTS="--height 40%"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


## wasmer -----------

export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

## asdf -----------

# This is required to ensure all asdf installations can be found

[ -f ~/.asdf/asdf.sh ] && source ~/.asdf/asdf.sh

## alias ----------- 

alias cat="bat"
alias ls="eza"
alias la="eza -a"
alias ll='eza -l -h'
alias loc='tokei --num-format commas'

## // git -----------  

alias grbm='git rebase main'
alias gw='git switch'
alias gwc='git switch -c '
alias gs='git status'
alias gl='git log --oneline -8'
alias gr='git reset'
alias gpl='git pull'
alias gps='git push'
alias gb='git branch'
alias gcm='git commit'
alias gcip="git add . && gcm -m 'wip'"
alias gpc='gh pr create'
alias grh='git rev-parse --short HEAD'

## // cargo --------- 

alias cr='cargo run'
alias crb='cargo run --bin'
alias cc='cargo check --tests'
alias ca='cargo add'
alias ct='cargo nextest run'
alias cb='cargo bench'

## // zellij ---------- 

alias zel=zellij

## // misc ---------- 

alias btop='btop -lc'
alias rm='rm -rf'
alias hex='hexyl'
alias kube=kubectl
alias pls=sudo
alias mkdir='mkdir -p'
alias nv=nvim

## funcs ------------ 

# find a directory and returns the path
fid() {
  if [[ $# -eq 1 ]]; then
    fd -t d --search-path "$1" | fzf
  else
    fd -t d | fzf
  fi
}

# find a directory and cd into it
fcd() {
  local dir=$(fid "$@")
  if [ -n "$dir" ]; then
	  cd "$dir"
  fi
}

# find a file and returns the path
fif() {
  fd -t f --exclude=node_modules "$@" | fzf
}

# find a file and open it with nvim
fof() {
  local file=$(fif "$@")
  if [ -n "$file" ]; then
	  nvim "$file"
  fi
}

# open the '~/Project' folder, and search through it 
project() {
  local dir=$(fid ~/Project)
  if [ -n "$dir" ]; then
	  cd "$dir"
  fi
}


export PATH="/usr/local/wasm/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.wasmtime/bin:$PATH"
export PATH="$HOME/odin:$PATH"
export PATH="$HOME/starknet-foundry/bin:$PATH"

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env


if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

alias claude='claude --dangerously-skip-permissions'
alias codex='codex --dangerously-bypass-approvals-and-sandbox' 

alias cl='claude'
alias cx='codex'
