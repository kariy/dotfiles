# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles management repository with Makefile-based installation, cross-platform support (macOS/Linux), and an auto-commit watcher service that continuously syncs changes to the `dotfiles` branch.

## Key Commands

```bash
make                  # Install everything (default target is `all`)
make zsh              # Symlink zsh config only
make git              # Symlink git config only
make nvim             # Symlink neovim config only
make vscode           # Symlink VS Code config only
make install-tools    # Install cargo/brew/apt tools (depends on rust, asdf targets)
make autocommit       # Start auto-commit background service (launchd/systemd)
make autocommit-stop  # Stop auto-commit service
```

CI runs on push/PR to the `dotfiles` branch, testing on both `ubuntu-latest` and `macos-latest`.

## Architecture

**Symlink strategy**: The Makefile creates symlinks from standard config locations back to this repo. Files under `.config/` are auto-discovered via `find` and symlinked to `~/.config/`. Top-level dotfiles (zshrc, gitconfig) use a pattern rule `$(HOME)/.%: %` to map `file` → `~/.file`. The `nvim/` directory is an exception — it lives at the repo root but symlinks to `~/.config/nvim/`.

**Tool installation**: Rust-based tools (bat, starship, tokei, fd-find, eza, hexyl, zoxide) are installed via `cargo` on all platforms for consistency. Only btop and fzf use platform-specific package managers (apt/brew).

**Auto-commit service** (`scripts/autocommit-watch.sh`): Polls `git status --porcelain` every 2s, debounces 30s, then commits and pushes. Managed as a launchd agent on macOS or systemd user service on Linux. Service definitions in `services/` use `__DOTFILE_PATH__` placeholder, substituted by `make autocommit` at install time.

**Makefile requires bash**: Uses `SHELL := /bin/bash` for `[[ ]]` conditionals. The `install-tools` target sources `~/.cargo/env` before running cargo commands to handle freshly-installed toolchains.

## Conventions

- The active branch is `dotfiles`, not `main`
- zshrc guards all optional dependencies with existence checks (`[ -f ... ] && source ...`) to avoid errors on machines where tools aren't installed
- zshrc uses `$HOME` instead of hardcoded user paths for portability
- Auto-commit messages follow the format: `chore(dotfiles): auto-commit YYYY-MM-DD HH:MM:SS`
