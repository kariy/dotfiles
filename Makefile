UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

# default path for config files
DOTCONFIG_PATH := $(HOME)/.config
VSCODE_CONFIG_PATH := $(HOME)/Library/Application\ Support/Code/User

.PHONY: check-commands install-tools starship zed vscode

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

# List of tools to install using cargo
CARGO_TOOLS = bat starship tokei fd-find
# Tools to install using apt or brew
OTHER_TOOLS = exa btop fzf

TOOLS = $(CARGO_TOOLS) $(OTHER_TOOLS)

# Checks if the tools are installed
check-commands:
	@for tool in $(TOOLS); do \
    	actual_name=$$tool; \
       	if [[ $$tool == "fd-find" ]]; then \
			actual_name="fd"; \
		fi; \
		if ! command -v $$actual_name > /dev/null 2>&1; then \
			echo $$tool; \
		fi; \
	done

install-tools:
	$(eval UNINSTALLED_TOOLS := $(shell make check-commands))
	@for tool in $(UNINSTALLED_TOOLS); do \
		echo "Installing $$tool..."; \
		if echo "$(CARGO_TOOLS)" | grep -w $$tool > /dev/null; then \
			cargo install $$tool; \
		elif echo "$(OTHER_TOOLS)" | grep -w $$tool > /dev/null; then \
			if [[ "$(UNAME)" == "Linux" ]]; then \
				sudo apt install $$tool; \
			elif [[ "$(UNAME)" == "Darwin" ]]; then \
				brew install $$tool; \
			fi \
		fi \
	done


all: git zsh zed starship install-tools
