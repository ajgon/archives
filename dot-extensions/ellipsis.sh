#!/usr/bin/env bash

config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

pkg.link() {
    if [ ! -d "${config_home}" ]; then
        mkdir -p "${config_home}"
    fi

    fs.link_file "${PKG_PATH}/aliases" "${config_home}/aliases"
    fs.link_file "${PKG_PATH}/exports" "${config_home}/exports"
    fs.link_file "${PKG_PATH}/extra" "${config_home}/extra"
    fs.link_file "${PKG_PATH}/functions" "${config_home}/functions"
    fs.link_file "${PKG_PATH}/aliases.$(os.platform)" "${config_home}/aliases.$(os.platform)"
    fs.link_file "${PKG_PATH}/exports.$(os.platform)" "${config_home}/exports.$(os.platform)"
    fs.link_file "${PKG_PATH}/extra.$(os.platform)" "${config_home}/extra.$(os.platform)"
    fs.link_file "${PKG_PATH}/functions.$(os.platform)" "${config_home}/functions.$(os.platform)"
    fs.link_file "${PKG_PATH}/kitty.$(os.platform)" "${config_home}/kitty"
    fs.link_file "${PKG_PATH}/alacritty.$(os.platform)" "${config_home}/alacritty"
    fs.link_file "${PKG_PATH}/notable.json" "$ELLIPSIS_HOME/.notable.json"
}

pkg.init() {
    config_home=${XDG_CONFIG_HOME:-$ELLIPSIS_HOME/.config}

    for file in "${config_home}"/{aliases*,exports*,extra*,functions*}; do
        [ -r "${file}" ] && source "$file"
    done
    unset file

    export GNUPGHOME=${XDG_CONFIG_HOME}/gnupg
    export SOLARGRAPH_CACHE=${XDG_CACHE_HOME}/solargraph
}
