UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

# default path for config files
DOTCONFIG_PATH := $(HOME)/.config
VSCODE_CONFIG_PATH := $(HOME)/Library/Application\ Support/Code/User

.PHONY: install-cli starship zed vscode

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

zsh: $(HOME)/.zshrc
	mkdir -p $(HOME)/.zsh
	ln -sf $(DOTFILE_PATH)/zsh/_git $(HOME)/.zsh/_git

git: $(HOME)/.gitconfig $(HOME)/.git-completions.bash

starship: $(HOME)/.config/starship.toml
	mkdir -p $(DOTCONFIG_PATH)
	ln -sf $(DOTFILE_PATH)/starship.toml $(DOTCONFIG_PATH)/starship.toml

zed:
	mkdir -p $(DOTCONFIG_PATH)/zed
	ln -sf $(DOTFILE_PATH)/zed/keymap.json $(DOTCONFIG_PATH)/zed/keymap.json
	ln -sf $(DOTFILE_PATH)/zed/settings.json $(DOTCONFIG_PATH)/zed/settings.json

vscode:
	mkdir -p $(VSCODE_CONFIG_PATH)
	ln -sf $(DOTFILE_PATH)/vscode/settings.json $(VSCODE_CONFIG_PATH)/settings.json
	ln -sf $(DOTFILE_PATH)/vscode/keybindings.json $(VSCODE_CONFIG_PATH)/keybindings.json

install-cli:
ifeq ($(UNAME), Linux)
	cargo install bat starship
	sudo apt install exa btop fd-find fzf
endif
ifeq ($(UNAME), Darwin)
	cargo install bat starship
	brew install exa btop fd fzf
endif

all: git zsh zed starship install-cli
