#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

pkg.install() {
    # Create tmux folders
    mkdir -p "${PKG_PATH}"/{plugins,resurrect}

    # Clone plugin manager
    git clone https://github.com/tmux-plugins/tpm "${PKG_PATH}/plugins/tpm"
}

pkg.link() {
    # Link package into ~/.config/tmux
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi
    fs.link_file "${PKG_PATH}" "${config_home}/tmux"

}

pkg.links() {
    local files="${config_home}/tmux"

    msg.bold "${1:-$PKG_NAME}"
    for file in $files; do
        local link="$(readlink "$file")"
        echo "$(path.relative_to_packages "$link") -> $(path.relative_to_home "$file")";
    done
}

pkg.unlink() {
    # Remove config dir
    rm "${config_home}/tmux"

    # Remove all links in the home folder
    hooks.unlink
}

pkg.uninstall() {
    : # No action
}

pkg.init() {
    config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}
    alias tmux="$(which tmux) -f ${config_home}/tmux/tmux.conf"
}
