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

    if [ ! -d "${ELLIPSIS_HOME}/.local/share" ]; then
        mkdir -p "${ELLIPSIS_HOME}/.local/share"
    fi

    fs.link_file fluxbox
    fs.link_file "${PKG_PATH}/parcellite" "${config_home}/parcellite"
    fs.link_file "${PKG_PATH}/xorg/xinitrc"
    fs.link_file "${PKG_PATH}/xorg/Xresources"
    fs.link_file "${PKG_PATH}/gtk-3.0" "${config_home}/gtk-3.0"
    fs.link_file "${PKG_PATH}/local/share/fonts" "${ELLIPSIS_HOME}/.local/share/fonts"
    fs.link_file "${PKG_PATH}/local/share/fonts" "${ELLIPSIS_HOME}/.fonts"
    fs.link_file "${PKG_PATH}/terminfo" "${ELLIPSIS_HOME}/.terminfo"

    fc-cache -fv
}

pkg.uninstall() {
    : # No action
}
