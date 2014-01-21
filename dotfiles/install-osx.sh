#!/usr/bin/env bash

# Install XCode
echo "Please install XCode from App Store, and then press ENTER"
open /Applications/App\ Store.app
read
echo "Please accept XCode license terms"
sudo xcodebuild -license
echo "Installing XCode Command Line Tools, press ENTER when done"
xcode-select --install > /dev/null 2>&1
read

# Setting up .ssh
echo "Configuring SSH, after pressing ENTER, please paste your private key file to the editor"
mkdir ~/.ssh 2> /dev/null
read
vim ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
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
brew tap caskroom/fonts
brew tap caskroom/versions

# Sync dotfiles
echo "Syncing .dotfiles..."
./bootstrap.sh

# Install brew and cask packages
echo "Installing homebrew packages..."
brew bundle ~/Brewfile
echo "Installing cask packages..."
./.cask
brew cask alfred link

# Install Sublime Packages
echo "Installing Sublime Text 2 packages..."
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages 2> /dev/null
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User 2> /dev/null
wget https://sublime.wbond.net/Package%20Control.sublime-package -O ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/Package\ Control.sublime-package
cp -r settings/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Package\ Control.sublime-settings 2> /dev/null
cp settings/st2.icns /Applications/Sublime\ Text\ 2.app/Contents/Resources/Sublime\ Text\ 2.icns
open /Applications/Sublime\ Text\ 2.app
echo "Press ENTER when Sublime finished installing all the packages"
read
cp -r settings/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Preferences.sublime-settings 2> /dev/null

# Configure TRIM
echo "Configure TRIM and press ENTER when ready"
open /Applications/Trim\ Enabler.app
read

# Configure Alfred
# TODO: Move it to .osx
echo "Configure ALFRED and press ENTER when ready"
open /Applications/Alfred\ Preferences.app
read

# Setting various osx options
echo "And now, time for some OSX magic..."
./.osx
source ~/.zshrc

echo "Install and configure these apps from the App Store, then press ENTER"
cat settings/.app-store-apps
read

e# Register propertiary applications
OLDIFS=$IFS
IFS="
"
for F in `cat settings/.register-apps`; do echo "Please register $F and press ENTER"; open /Applications/$F; read; done
IFS=$OLDIFS

cho "Configure owncloud"
open /Applications/owncloud.app
read

echo "Configure keepassx"
open /Application/KeePassX.app

# Work complete
echo "Work complete"
say -v zarvox "Work complete"

