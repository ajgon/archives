#!/usr/bin/env bash
CURRENT_DIR=$(pwd)
export CURRENT_DIR

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Update system
if [ ! -f .step0 ]; then
  echo "Updating system..."
  sudo softwareupdate -i -a
  touch .step0
  echo "Restart is required, press Enter"
  read -r
  sudo reboot
fi

# Enable TRIM
if [ ! -f .step1 ]; then
  echo "Installing TRIM Enabler..."
  curl -L -o packages/TrimEnabler.dmg https://www.dropbox.com/s/r1z1vt8xy1qey9h/TrimEnabler.dmg
  hdiutil mount packages/TrimEnabler.dmg
  cp -r "/Volumes/Trim Enabler/Trim Enabler.app" /Applications
  hdiutil unmount "/Volumes/Trim Enabler/Trim Enabler.app"
  echo "Please enable TRIM and press Enter to restart your Mac"
  open "/Applications/Trim Enabler.app"
  read -r
  touch .step1
  sudo reboot
fi

# Enable OSX developer extensions
if [ ! -f .step2 ]; then
  echo "Installing XCode Command Line Tools, press ENTER when done"
  xcode-select --install > /dev/null 2>&1
  read -r
  touch .step2
fi

# Install developer shell extensions
if [ ! -f .step3 ]; then
  echo "Installing oh-my-zsh and it's plugins..."
  curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew tap Homebrew/bundle
  brew update
  brew upgrade
  brew bundle
  brew cleanup

  echo "Installing nvm..."
  rm -rf ~/.nvm
  curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
  # shellcheck disable=SC1091
  # shellcheck source=~/.nvm/nvm.sh
  [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
  nvm install stable
  nvm alias default stable
  nvm use stable

  echo "Installing rvm..."
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  rm -rf ~/.rvm
  curl -sSL https://get.rvm.io | bash -s head
  # shellcheck disable=SC1091
  source ~/.rvm/scripts/rvm

  echo "Installing dotfiles..."
  rm -rf ~/.ackrc ~/.aliases ~/.exports ~/.extra ~/.fun ~/.functions ~/.gitconfig ~/.gitignore ~/.inputrc ~/.osx ~/.profile.osx.d ~/.screenrc ~/.tmux.conf ~/.vim ~/.vimrc ~/.zshrc ~/.dotfiles
  git clone https://github.com/ajgon/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles || exit
  /bin/zsh -c './bootstrap --new-setup'
  cd "${CURRENT_DIR}" || exit
  vim +NeoBundleInstall +qall

  touch .step3
fi

# Install apps
if [ ! -f .step4 ]; then
  echo "Installing Alfred..."
  curl -L -o packages/alfred2.zip https://www.dropbox.com/s/humo6ewd7ylj2es/alfred2.zip
  unzip packages/alfred2.zip -d packages
  cp -r "packages/Alfred 2.app" /Applications/
  # Disable spotlight GUI (without indexing)
  sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
  echo "Change Alfred 2 shortcut, enable clipboard history, activate powerpack and press Enter"
  open "/Applications/Alfred 2.app"
  read -r

  echo "Installing Google Chrome..."
  curl -L -o packages/googlechrome.dmg https://www.dropbox.com/s/5we7xp1szgw5ioq/googlechrome.dmg
  hdiutil mount "packages/googlechrome.dmg"
  cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/
  hdiutil unmount "/Volumes/Google Chrome"

  echo "Installing Firefox..."
  curl -L -o packages/Firefox.dmg https://www.dropbox.com/s/xpf9l69tlmx0zmi/Firefox.dmg
  hdiutil mount "packages/Firefox.dmg"
  cp -R /Volumes/Firefox/Firefox.app /Applications
  hdiutil unmount /Volumes/Firefox

  echo "Installing Gimp..."
  curl -L -o packages/Gimp.dmg https://www.dropbox.com/s/l9r5zegx0p1oxpz/Gimp.dmg
  hdiutil mount "packages/Gimp.dmg"
  cp -R /Volumes/Gimp*/GIMP.app /Applications
  hdiutil unmount /Volumes/Gimp*

  echo "Installing iTerm2..."
  curl -L -o packages/iTerm2.zip https://www.dropbox.com/s/5urdahw84k96ygf/iTerm2.zip
  unzip packages/iTerm2.zip -d packages
  cp -R packages/iTerm.app /Applications

  echo "Installing ownCloud..."
  curl -L -o packages/ownCloud.pkg https://www.dropbox.com/s/k1cjbb2syw1g7z3/ownCloud.pkg
  sudo installer -pkg packages/ownCloud.pkg -target /

  echo "Installing skype..."
  curl -L -o packages/skype.dmg https://www.dropbox.com/s/mmypvqe20twf01x/skype.dmg
  hdiutil mount "packages/skype.dmg"
  cp -R /Volumes/Skype/Skype.app /Applications
  hdiutil unmount /Volumes/Skype

  echo "Installing Toggl..."
  curl -L -o packages/Toggl.dmg https://www.dropbox.com/s/7bbk9cmqqx02h20/Toggl.dmg
  hdiutil mount "packages/Toggl.dmg"
  cp -R /Volumes/TogglDesktop/TogglDesktop.app /Applications
  hdiutil unmount /Volumes/TogglDesktop

  echo "Installing Spotify..."
  curl -L -o packages/Spotify.zip https://www.dropbox.com/s/l1b9eia3sb3lrxu/Spotify.zip
  unzip packages/Spotify.zip -d packages
  open "packages/Install Spotify.app"

  echo "Installing Tunnelblick..."
  curl -L -o packages/Tunnelblick.dmg https://www.dropbox.com/s/05sfv0pja3vl9d5/Tunnelblick.dmg
  hdiutil mount "packages/Tunnelblick.dmg"
  cp -R /Volumes/Tunnelblick/Tunnelblick.app /Applications
  hdiutil unmount "/Volumes/Tunnelblick"

  echo "Installing Sublime Text 3..."
  curl -L -o packages/Sublime.dmg https://www.dropbox.com/s/7e3key50blljy50/Sublime.dmg
  hdiutil mount "packages/Sublime.dmg"
  cp -R "/Volumes/Sublime Text/Sublime Text.app" /Applications
  hdiutil unmount "/Volumes/Sublime Text"
  mkdir -p "${HOME}/Library/Application Support/Sublime Text 3/Installed Packages"
  mkdir -p "${HOME}/Library/Application Support/Sublime Text 3/Packages/User"
  curl -L -o "${HOME}/Library/Application Support/Sublime Text 3/Installed Packages/Package Control.sublime-package" "https://sublime.wbond.net/Package%20Control.sublime-package"
  cp "settings/Package Control.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User"
  open "/Applications/Sublime Text.app"
  echo "Allow Sublime Text to install all packages, then quit it"
  read -r
  cp "settings/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/"

  # App Store
  for app in divvy todoist 1Password ReadKit "Tube Controller" Sip CleanMyDrive "The Unarchiver" Twitter; do
    echo "Install ${app} from appStore and press Enter"
    read -r
  done

  touch .step4
fi

# Customizing the environment
if [ ! -f .step5 ]; then
  # Hide all app icons, except the active ones
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock static-only -bool TRUE

  # Show hidden apps
  defaults write com.apple.dock showhidden -bool TRUE

  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0

  # Remove the animation when hiding/showing the Dock
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Increase sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  # Enable right click on mouse
  defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton

  # Enable Smart Zoom
  defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture 1

  # Enable Tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Enable Three Finger Drag
  defaults write com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerDrag 1
  defaults write com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerHorizSwipeGesture 0
  defaults write com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerVertSwipeGesture 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture 0

  # Trackpad: map bottom right corner to right-click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  # Kill pesky emojis shortcut
  defaults write -g NSUserKeyEquivalents -dict-add 'Emoji & Symbols' '\0'

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Set a blazingly fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 0

  # Set the timezone; see `systemsetup -listtimezones` for other values
  systemsetup -settimezone "Europe/Warsaw" > /dev/null

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Empty Trash securely by default
  defaults write com.apple.finder EmptyTrashSecurely -bool true

  # Show the ~/Library folder
  chflags nohidden ~/Library

  # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

  # Disable automatic spell checking
  defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  # Disable local Time Machine backups
  hash tmutil &> /dev/null && sudo tmutil disablelocal

  # Don’t display the annoying prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false

  # Set default directory for preferences before setting them
  defaults write com.googlecode.iterm2 NSNavLastRootDirectory -string "$HOME/Library/Preferences"

  # Set default preferences
  cp settings/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
  plutil -convert binary1 ~/Library/Preferences/com.googlecode.iterm2.plist

  # Configure divvy
  defaults write com.mizage.divvy globalHotkey '{ "keyCode" = 49; "modifiers" = 768;  }'
  defaults write com.mizage.divvy showMenuIcon 0
  defaults write com.mizage.divvy useGlobalHotkey 1
  open -a safari "divvy://import/YnBsaXN0MDDUAQIDBAUIXV5UJHRvcFgkb2JqZWN0c1gkdmVyc2lvblkkYXJjaGl2ZXLRBgdUcm9vdIABrgkKFCssMzw9RkdPUFhZVSRudWxs0gsMDQ5WJGNsYXNzWk5TLm9iamVjdHOADaUPEBESE4ACgAWAB4AJgAvdFRYXGBkaGxwdHh8gCyEiIyQlIiYnKCQhJipfEBJzZWxlY3Rpb25FbmRDb2x1bW5fEBFzZWxlY3Rpb25TdGFydFJvd1xrZXlDb21ib0NvZGVXZW5hYmxlZF1rZXlDb21ib0ZsYWdzXxAUc2VsZWN0aW9uU3RhcnRDb2x1bW5bc2l6ZUNvbHVtbnNac3ViZGl2aWRlZFduYW1lS2V5Vmdsb2JhbF8QD3NlbGVjdGlvbkVuZFJvd1hzaXplUm93cxAFEAAQMQkSABQAABAGCIADCYAEVEZ1bGzSLS4vMlgkY2xhc3Nlc1okY2xhc3NuYW1lojAxWFNob3J0Y3V0WE5TT2JqZWN0WFNob3J0Y3V03RUWFxgZGhscHR4fIAs0IjUkNyImJzkkISYqEAIQewkSAJQAAAiABgmABFRMZWZ03RUWFxgZGhscHR4fIAshIj4kQEEmJ0MkISYqEHwJEgCUAAAQAwiACAmABFVSaWdodN0VFhcYGRobHB0eHyALISJIJEoiJidMJDQmKhB+CRIAlAAACIAKCYAEUlVw3RUWFxgZGhscHR4fIAshQVEkUyImJ1UkISYqEH0JEgCUAAAIgAwJgARURG93btItLlpbo1tcMV5OU011dGFibGVBcnJheVdOU0FycmF5EgABhqBfEA9OU0tleWVkQXJjaGl2ZXIACAARABYAHwAoADIANQA6ADwASwBRAFYAXQBoAGoAcAByAHQAdgB4AHoAlQCqAL4AywDTAOEA+AEEAQ8BFwEeATABOQE7AT0BPwFAAUUBRwFIAUoBSwFNAVIBVwFgAWsBbgF3AYABiQGkAaYBqAGpAa4BrwGxAbIBtAG5AdQB1gHXAdwB3gHfAeEB4gHkAeoCBQIHAggCDQIOAhACEQITAhYCMQIzAjQCOQI6AjwCPQI/AkQCSQJNAlwCZAJpAAAAAAAAAgEAAAAAAAAAXwAAAAAAAAAAAAAAAAAAAns="
  for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "Dock" \
    "Finder" "Mail" "Messages" "Safari" "SizeUp" "SystemUIServer" \
    "Transmission" "Twitter" "iCal"; do
    killall "${app}" > /dev/null 2>&1
  done

  touch .step5
  echo "Restart is required, press Enter"
  read -r
  sudo reboot
fi
