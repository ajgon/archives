#!/usr/bin/env bash

# Install XCode
echo "Please install XCode from App Store, and then press ENTER"
open /Applications/App\ Store.app
read
echo "Please accept XCode license terms"
sudo xcodebuild -license
echo "Installing XCode Command Line Tools, press ENTER when done"
xcode-select --install
read

# Setting up .ssh
echo "Configuring SSH, after pressing ENTER, please paste your private key file to the editor"
mkdir ~/.ssh
read
vim ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

# Install oh-my-zsh
echo "Installing oh-my-zsh and it's plugins..."
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install homebrew and cask
echo "Installing homebrew and cask..."
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew tap phinze/cask
brew install brew-cask

# Sync dotfiles
echo "Syncing .dotfiles..."
./bootstrap.sh

# Install brew and cask packages
echo "Installing homebrew packages..."
brew bundle ~/Brewfile
echo "Installing cask packages..."
./.cask

# Configure TRIM
echo "Configure TRIM and press ENTER when ready"
open /Applications/Trim\ Enabler.app

# Setting various osx options
echo "And now, time for some OSX magic..."
./.osx

# Work complete
echo "Work complete"
say -v zarvox "Work complete"

