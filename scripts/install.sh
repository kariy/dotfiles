#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/kariy/dotfiles.git"
BRANCH="dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

fmt_info()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
fmt_error() { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }

# --- pre-flight checks ---

if ! command -v git >/dev/null 2>&1; then
  fmt_error "git is not installed. Please install git first."
  exit 1
fi

if [ "$(uname)" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    fmt_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
fi

# --- clone or update ---

if [ -d "$DOTFILES_DIR" ]; then
  fmt_info "Dotfiles already cloned at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH"
else
  fmt_info "Cloning dotfiles..."
  git clone -b "$BRANCH" "$REPO" "$DOTFILES_DIR"
fi

# --- install ---

fmt_info "Running make all..."
make -C "$DOTFILES_DIR" all

fmt_info "Done! Restart your shell or run: source ~/.zshrc"
