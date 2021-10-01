    config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}
#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}
cache_home=${XDG_CACHE_HOME:-$ELLIPSIS_HOME/.cache}

pkg.install() {
    # Create vim folders
    mkdir -p "${PKG_PATH}"/sessions

    # Set VIMINIT
    export VIMINIT=":set runtimepath+=${config_home}/vim|:source ${config_home}/vim/vimrc"
}

pkg.link() {
    # Link package into ~/.config/vim
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi
    if [ ! -d "${cache_home}/vim" ]; then
        mkdir -p "${cache_home}/vim"
    fi
    fs.link_file "${PKG_PATH}" "${config_home}/vim"

    # Install plugins
    # update plugins (clean than install and update)
    echo "Installing vim plugins."
    PKG_PATH=$PKG_PATH\
        vim -E -s -u "${config_home}/vim/vimrc" +PlugInstall +qall

    # Install YouCompleteMe
    if [ -f "${PKG_PATH}/bundle/YouCompleteMe/install.py" ]; then
        python3 "${PKG_PATH}/bundle/YouCompleteMe/install.py"
    fi
}

pkg.links() {
    local files="${config_home}/vim"

    msg.bold "${1:-$PKG_NAME}"
    for file in $files; do
        local link="$(readlink "$file")"
        echo "$(path.relative_to_packages "$link") -> $(path.relative_to_home "$file")";
    done
}

pkg.pull() {
    # Update dot-vim repo
    git.pull

    # update plugins (clean than install and update)
    PKG_PATH=$PKG_PATH\
        vim +PlugClean +PlugInstall +qall
}

pkg.unlink() {
    # Remove config dir
    rm "${config_home}/vim"

    # Remove all links in the home folder
    hooks.unlink
}

pkg.uninstall() {
    : # No action
}

pkg.init() {
    config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

    export VIMINIT=":set runtimepath+=${config_home}/vim|:source ${config_home}/vim/vimrc"
    export VIMDOTDIR="${config_home}/vim"
    alias ctags="$(which ctags) --options=${config_home}/vim/ctags"
}
