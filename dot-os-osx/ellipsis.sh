#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

pkg.install() {
    packages=(extensions git tmux vim zsh)
    for package in ${packages[@]}; do
        ellipsis install "ajgon/$package"
    done
}

pkg.link() {
    # Link package into ~/.config/git
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi

    files=(alacritty karabiner)
    for file in ${files[@]}; do
        fs.link_file "${PKG_PATH}/${file}" "${config_home}/${file}"
    done
}

pkg.init() {
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS=--require-sha
}
