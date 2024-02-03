source <(/usr/local/bin/starship init zsh --print-full-init)

. ~/z.sh

zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
fpath=(~/.zsh $fpath)

# bun completions
[ -s "/Users/kariy/.bun/_bun" ] && source "/Users/kariy/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

## My awesome aliases

alias cat="bat"
alias ls="exa"
alias la="exa -a"
alias ll='exa -l'

## git
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

## cargo
alias cr='cargo run'
alias crb='cargo run --bin'
alias cc='cargo check'
alias ca='cargo add'
alias ct='cargo nextest run'

## misc
alias btop='btop -lc'
alias rm='rm -rf'

### search

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

export FZF_DEFAULT_OPTS="--height 40%"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="/usr/local/wasm/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
