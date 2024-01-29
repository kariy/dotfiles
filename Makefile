DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

$(HOME)/.config/starship.toml:
	mkdir -p $(HOME)/.config
	ln -sf $(DOTFILE_PATH)/starship.toml $(HOME)/.config/starship.toml

$(HOME)/.config/zed/settings.json:
	mkdir -p $(HOME)/.config/zed
	ln -sf $(DOTFILE_PATH)/zed/settings.json $(HOME)/.config/zed/settings.json

$(HOME)/.config/zed/keymap.json:
	mkdir -p $(HOME)/.config/zed
	ln -sf $(DOTFILE_PATH)/zed/keymap.json $(HOME)/.config/zed/keymap.json

$(HOME)/Library/Application\ Support/Code/User/settings.json:
	mkdir -p $(HOME)/Library/Application\ Support/Code/User
	ln -sf $(DOTFILE_PATH)/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json

zsh: $(HOME)/.zshrc
git: $(HOME)/.gitconfig
starship: $(HOME)/.config/starship.toml
vscode: $(HOME)/Library/Application\ Support/Code/User/settings.json
zed: $(HOME)/.config/zed/keymap.json $(HOME)/.config/zed/settings.json

all: git zsh zed starship
