const INSTALL_SCRIPT = `#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/kariy/dotfiles.git"
BRANCH="dotfiles"
DOTFILES_DIR="$HOME/dotfiles"
AUTO_YES=false

# --- helpers ---

fmt_info()    { printf '\\033[1;34m:: %s\\033[0m\\n' "$*"; }
fmt_success() { printf '\\033[1;32m:: %s\\033[0m\\n' "$*"; }
fmt_warn()    { printf '\\033[1;33m:: %s\\033[0m\\n' "$*"; }
fmt_error()   { printf '\\033[1;31m:: %s\\033[0m\\n' "$*" >&2; }

confirm() {
  if $AUTO_YES; then return 0; fi
  printf '\\033[1;33m:: %s [Y/n] \\033[0m' "$1"
  read -r reply
  case "$reply" in
    [nN]*) return 1 ;;
    *) return 0 ;;
  esac
}

# Select from a list. Sets SELECTED array with chosen indices.
select_components() {
  if $AUTO_YES; then
    SELECTED=()
    local i
    for ((i = 0; i < \${#COMPONENTS[@]}; i++)); do
      SELECTED+=("$i")
    done
    return 0
  fi

  echo ""
  fmt_info "Select components to install (space-separated numbers, or 'a' for all):"
  echo ""
  local i
  for ((i = 0; i < \${#COMPONENTS[@]}; i++)); do
    printf "  \\033[1m%d)\\033[0m %s\\n" "$((i + 1))" "\${COMPONENTS[$i]}"
  done
  echo ""
  printf '\\033[1;33m:: Choice [a]: \\033[0m'
  read -r choices

  SELECTED=()
  if [ -z "$choices" ] || [ "$choices" = "a" ] || [ "$choices" = "A" ]; then
    for ((i = 0; i < \${#COMPONENTS[@]}; i++)); do
      SELECTED+=("$i")
    done
  else
    for num in $choices; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "\${#COMPONENTS[@]}" ]; then
        SELECTED+=("$((num - 1))")
      else
        fmt_warn "Ignoring invalid selection: $num"
      fi
    done
  fi
}

# --- parse args ---

usage() {
  cat <<USAGE
Usage: install.sh [OPTIONS]

Options:
  -y          Non-interactive mode (install everything, no prompts)
  -d PATH     Set dotfiles directory (default: ~/dotfiles)
  -h          Show this help message

Examples:
  curl -fsSL https://env.lactoseintolerant.dev/install.sh | bash              # interactive
  curl -fsSL https://env.lactoseintolerant.dev/install.sh | bash -s -- -y     # install all
USAGE
  exit 0
}

while getopts "yhd:" opt; do
  case "$opt" in
    y) AUTO_YES=true ;;
    d) DOTFILES_DIR="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# --- pre-flight checks ---

fmt_info "kariy/dotfiles installer"
echo ""

if ! command -v git >/dev/null 2>&1; then
  fmt_error "git is not installed. Please install git first."
  exit 1
fi

if [ "$(uname)" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    if confirm "Homebrew is required on macOS. Install it?"; then
      fmt_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    else
      fmt_warn "Skipping Homebrew. Some tools (btop, fzf, dust) may fail to install."
    fi
  fi
fi

# --- clone or update ---

if [ -d "$DOTFILES_DIR" ]; then
  fmt_info "Dotfiles found at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH"
else
  if confirm "Clone dotfiles to $DOTFILES_DIR?"; then
    git clone -b "$BRANCH" "$REPO" "$DOTFILES_DIR"
  else
    fmt_error "Cannot proceed without dotfiles. Exiting."
    exit 1
  fi
fi

# --- component selection ---

COMPONENTS=(
  "Shell config (zshrc/bashrc)"
  "Git config"
  "Neovim config"
  "VS Code config"
  "XDG configs (starship, skhd, yabai, zed)"
  "CLI tools (bat, eza, fd, fzf, starship, etc.)"
  "AI agents (Claude Code, Codex)"
  "Autocommit service"
)

TARGETS=(
  "shell"
  "git"
  "nvim"
  "vscode"
  "\\$(DOTCONFIG_TARGETS)"
  "tools"
  "agents"
  "autocommit"
)

select_components

if [ \${#SELECTED[@]} -eq 0 ]; then
  fmt_warn "Nothing selected. Exiting."
  exit 0
fi

MAKE_TARGETS=""
for i in "\${SELECTED[@]}"; do
  MAKE_TARGETS="$MAKE_TARGETS \${TARGETS[$i]}"
done

# --- install ---

echo ""
fmt_info "Installing:$(for i in "\${SELECTED[@]}"; do printf ' [%s]' "\${COMPONENTS[$i]}"; done)"
echo ""

make -C "$DOTFILES_DIR" $MAKE_TARGETS

echo ""
fmt_success "Installation complete!"

if [ -n "$ZSH_VERSION" ] 2>/dev/null || [ "$(basename "$SHELL")" = "zsh" ]; then
  fmt_info "Run: source ~/.zshrc"
else
  fmt_info "Run: source ~/.bashrc"
fi
`;

export default {
  async fetch() {
    return new Response(INSTALL_SCRIPT, {
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": "public, max-age=300",
      },
    });
  },
};
