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

.PHONY: check-tools-installed install-tools vscode zsh nvim rust asdf all

$(HOST_DOTCONFIG_PATH)/%: $(DOTCONFIG_PATH)/%
	@mkdir -p $(@D)
	cp $< $@
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

# List of tools to install using cargo
CARGO_TOOLS = bat starship tokei fd-find
# Tools to install using apt or brew
OTHER_TOOLS = eza btop fzf hexyl zoxide

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

install-tools: rust asdf
	$(eval UNINSTALLED_TOOLS := $(shell make check-tools-installed))
	@for tool in $(UNINSTALLED_TOOLS); do \
		echo "Installing $$tool..."; \
		if echo "$(CARGO_TOOLS)" | grep -w $$tool > /dev/null; then \
			. "$(HOME)/.cargo/env" && cargo install $$tool; \
		elif echo "$(OTHER_TOOLS)" | grep -w $$tool > /dev/null; then \
			if [[ "$(UNAME)" == "Linux" ]]; then \
				sudo apt install -y $$tool; \
			elif [[ "$(UNAME)" == "Darwin" ]]; then \
				brew install $$tool; \
			fi \
		fi \
	done

all: $(DOTCONFIG_TARGETS) git zsh nvim install-tools
