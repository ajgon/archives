#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

pkg.link() {
    fs.link_file zshenv

    # Link package into ~/.config/zsh
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi
    mkdir -p "${config_home}/markers"
    fs.link_file "${PKG_PATH}/zsh" "${config_home}/zsh"
    fs.link_file "${PKG_PATH}/markers/common.txt" "${config_home}/markers/common.txt"
    fs.link_file "${PKG_PATH}/markers/$(os.platform).txt" "${config_home}/markers/$(os.platform).txt"

}

pkg.links() {
    local files="${config_home}/zsh"

    msg.bold "${1:-$PKG_NAME}"
    for file in $files; do
        local link="$(readlink "$file")"
        echo "$(path.relative_to_packages "$link") -> $(path.relative_to_home "$file")";
    done
}

pkg.unlink() {
    # Remove config dir
    rm "${config_home}/zsh"

    # Remove all links in the home folder
    hooks.unlink
}

pkg.uninstall() {
    : # No action
}
