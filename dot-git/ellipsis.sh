#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

pkg.install() {
    rm -rf "${HOME}/.gitconfig" "${HOME}/.gitignore" "${HOME}/.gitattributes"
}

pkg.link() {
    # Link package into ~/.config/git
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi
    fs.link_file "${PKG_PATH}" "${config_home}/git"

    if which qubes-gpg-client-wrapper; then
        git config --global gpg.program "qubes-gpg-client-wrapper"
    fi
    git config --global core.pager "${config_home}/git/diff-highlight"
}

pkg.links() {
    local files="${config_home}/git"

    msg.bold "${1:-$PKG_NAME}"
    for file in $files; do
        local link="$(readlink "$file")"
        echo "$(path.relative_to_packages "$link") -> $(path.relative_to_home "$file")";
    done
}

pkg.unlink() {
    # Remove config dir
    rm "${config_home}/git"

    # Remove all links in the home folder
    hooks.unlink
}

pkg.uninstall() {
    : # No action
}

pkg.init() {
    export PATH="$XDG_CONFIG_HOME/git/git-fuzzy/bin:$PATH"
}
