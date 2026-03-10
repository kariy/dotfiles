SHELL := /bin/bash
UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

DOTCONFIG_PATH := $(DOTFILE_PATH)/.config
HOST_DOTCONFIG_PATH := $(HOME)/.config

VSCODE_CONFIG_PATH := $(HOME)/Library/Application\ Support/Code/User

# Find all config files under any subdirectory of source
DOTCONFIG_FILES := $(shell find $(DOTCONFIG_PATH) -type f)

# Define targets based on source config files, substituting the source directory with the destination directory
DOTCONFIG_TARGETS := $(DOTCONFIG_FILES:$(DOTCONFIG_PATH)/%=$(HOST_DOTCONFIG_PATH)/%)

.DEFAULT_GOAL := all
.PHONY: check-tools-installed tools vscode zsh nvim rust asdf nvm pyenv uv agents autocommit autocommit-stop all

$(HOST_DOTCONFIG_PATH)/%: $(DOTCONFIG_PATH)/%
	@mkdir -p $(@D)
	ln -sf $< $@

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

zsh: $(HOME)/.zshrc
	mkdir -p $(HOME)/.zsh
	ln -sf $(DOTFILE_PATH)/zsh/_git $(HOME)/.zsh/_git

git: $(HOME)/.gitconfig $(HOME)/.git-completion.bash

nvim:
	mkdir -p $(HOST_DOTCONFIG_PATH)/nvim
	ln -sf $(DOTFILE_PATH)/nvim/init.vim $(HOST_DOTCONFIG_PATH)/nvim/init.vim

vscode:
	mkdir -p $(VSCODE_CONFIG_PATH)
	ln -sf $(DOTFILE_PATH)/vscode/settings.json $(VSCODE_CONFIG_PATH)/settings.json
	ln -sf $(DOTFILE_PATH)/vscode/keybindings.json $(VSCODE_CONFIG_PATH)/keybindings.json

# Tools to install using cargo (Rust-based, consistent across platforms)
CARGO_TOOLS = bat starship tokei fd-find eza hexyl zoxide zellij
# Tools to install using apt or brew
OTHER_TOOLS = btop fzf

TOOLS = $(CARGO_TOOLS) $(OTHER_TOOLS)

# Checks if the tools are installed
check-tools-installed:
	@for tool in $(TOOLS); do \
    	actual_name=$$tool; \
       	if [[ $$tool == "fd-find" ]]; then \
			actual_name="fd"; \
		fi; \
		if ! command -v $$actual_name > /dev/null 2>&1; then \
			echo $$tool; \
		fi; \
	done

rust:
	@if ! command -v rustup > /dev/null 2>&1; then \
		echo "Installing Rust toolchain via rustup..."; \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
	else \
		echo "Rust toolchain already installed."; \
	fi

asdf:
	@if [ ! -d "$(HOME)/.asdf" ]; then \
		echo "Installing asdf..."; \
		git clone https://github.com/asdf-vm/asdf.git $(HOME)/.asdf --branch v0.15.0; \
	else \
		echo "asdf already installed."; \
	fi

nvm:
	@if [ ! -d "$(HOME)/.nvm" ]; then \
		echo "Installing nvm..."; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash; \
		. "$(HOME)/.nvm/nvm.sh" && nvm install --lts; \
	else \
		echo "nvm already installed."; \
	fi

pyenv:
	@if ! command -v pyenv > /dev/null 2>&1; then \
		echo "Installing pyenv..."; \
		curl -fsSL https://pyenv.run | bash; \
		export PATH="$(HOME)/.pyenv/bin:$$PATH" && \
		eval "$$(pyenv init -)" && \
		echo "Installing Python (latest)..." && \
		pyenv install -s 3 && \
		pyenv global 3; \
	else \
		echo "pyenv already installed."; \
	fi

uv:
	@if ! command -v uv > /dev/null 2>&1; then \
		echo "Installing uv..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	else \
		echo "uv already installed."; \
	fi

agents: nvm
	@if ! command -v claude > /dev/null 2>&1; then \
		echo "Installing Claude Code..."; \
		if [[ "$(UNAME)" == "Darwin" ]]; then \
			curl -fsSL https://claude.ai/install.sh | bash; \
		else \
			. "$(HOME)/.nvm/nvm.sh" && npm i -g @anthropic-ai/claude-code; \
		fi \
	else \
		echo "Claude Code already installed."; \
	fi
	@if ! command -v codex > /dev/null 2>&1; then \
		echo "Installing Codex..."; \
		if [[ "$(UNAME)" == "Darwin" ]]; then \
			brew install codex; \
		else \
			. "$(HOME)/.nvm/nvm.sh" && npm i -g @openai/codex; \
		fi \
	else \
		echo "Codex already installed."; \
	fi

tools: rust asdf nvm pyenv uv
	$(eval UNINSTALLED_TOOLS := $(shell . "$(HOME)/.cargo/env" 2>/dev/null; make check-tools-installed))
	@. "$(HOME)/.cargo/env" 2>/dev/null; \
	for tool in $(UNINSTALLED_TOOLS); do \
		echo "Installing $$tool..."; \
		if echo "$(CARGO_TOOLS)" | grep -w $$tool > /dev/null; then \
			cargo install $$tool; \
		elif echo "$(OTHER_TOOLS)" | grep -w $$tool > /dev/null; then \
			if [[ "$(UNAME)" == "Linux" ]]; then \
				sudo apt install -y $$tool; \
			elif [[ "$(UNAME)" == "Darwin" ]]; then \
				brew install $$tool; \
			fi \
		fi \
	done
	@if ! command -v dust > /dev/null 2>&1; then \
		echo "Installing dust..."; \
		curl -sSfL https://raw.githubusercontent.com/bootandy/dust/refs/heads/master/install.sh | sh; \
	else \
		echo "dust already installed."; \
	fi
	@if ! command -v wrangler > /dev/null 2>&1; then \
		echo "Installing wrangler (Cloudflare R2 CLI)..."; \
		. "$(HOME)/.nvm/nvm.sh" && npm i -g wrangler; \
	else \
		echo "wrangler already installed."; \
	fi

LAUNCHD_PLIST := $(HOME)/Library/LaunchAgents/com.dotfiles.autocommit.plist
SYSTEMD_SERVICE := $(HOST_DOTCONFIG_PATH)/systemd/user/dotfiles-autocommit.service

autocommit:
	@if [[ "$(UNAME)" == "Darwin" ]]; then \
		mkdir -p $(HOME)/Library/LaunchAgents; \
		sed 's|__DOTFILE_PATH__|$(DOTFILE_PATH)|g' $(DOTFILE_PATH)/services/com.dotfiles.autocommit.plist > $(LAUNCHD_PLIST); \
		launchctl bootout gui/$$(id -u) $(LAUNCHD_PLIST) 2>/dev/null || true; \
		launchctl bootstrap gui/$$(id -u) $(LAUNCHD_PLIST); \
		echo "Autocommit service started (launchd)."; \
	elif [[ "$(UNAME)" == "Linux" ]]; then \
		mkdir -p $(HOST_DOTCONFIG_PATH)/systemd/user; \
		sed 's|__DOTFILE_PATH__|$(DOTFILE_PATH)|g' $(DOTFILE_PATH)/services/dotfiles-autocommit.service > $(SYSTEMD_SERVICE); \
		systemctl --user daemon-reload; \
		systemctl --user enable --now dotfiles-autocommit.service; \
		echo "Autocommit service started (systemd)."; \
	fi

autocommit-stop:
	@if [[ "$(UNAME)" == "Darwin" ]]; then \
		launchctl bootout gui/$$(id -u) $(LAUNCHD_PLIST) 2>/dev/null && \
		rm -f $(LAUNCHD_PLIST) && \
		echo "Autocommit service stopped (launchd)." || \
		echo "Autocommit service is not running."; \
	elif [[ "$(UNAME)" == "Linux" ]]; then \
		systemctl --user disable --now dotfiles-autocommit.service 2>/dev/null && \
		rm -f $(SYSTEMD_SERVICE) && \
		systemctl --user daemon-reload && \
		echo "Autocommit service stopped (systemd)." || \
		echo "Autocommit service is not running."; \
	fi

all: $(DOTCONFIG_TARGETS) git zsh nvim tools agents
