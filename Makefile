DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

$(HOME)/.config/zed/settings.json:
	mkdir -p $(HOME)/.config/zed
	ln -sf $(DOTFILE_PATH)/zed/settings.json $(HOME)/.config/zed/settings.json

$(HOME)/.config/zed/keymap.json:
	mkdir -p $(HOME)/.config/zed
	ln -sf $(DOTFILE_PATH)/zed/keymap.json $(HOME)/.config/zed/keymap.json

$(HOME)/Library/Application\ Support/Code/User/settings.json:
	mkdir -p $(HOME)/Library/Application\ Support/Code/User
	ln -sf $(DOTFILE_PATH)/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json

git: $(HOME)/.gitconfig
zsh: $(HOME)/.zshrc
vscode: $(HOME)/Library/Application\ Support/Code/User/settings.json
zed: $(HOME)/.config/zed/keymap.json $(HOME)/.config/zed/settings.json

all: git zsh zed
