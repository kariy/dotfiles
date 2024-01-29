DOTFILE_PATH := $(shell pwd)

# default path for config files
DOTCONFIG_PATH := $(HOME)/.config
VSCODE_CONFIG_PATH := $(HOME)/Library/Application\ Support/Code/User

$(HOME)/.%: .%
	ln -sf $(DOTFILE_PATH)/$^ $@

zsh: $(HOME)/.zshrc
git: $(HOME)/.gitconfig

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

all: git zsh zed starship
