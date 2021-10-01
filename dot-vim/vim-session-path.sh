#!/usr/bin/env sh
config_home=${XDG_CONFIG_HOME:-$HOME/.config}

if [ "$(uname)" = "Darwin" ]; then
    SUM="$(pwd | md5)"
else
    SUM="$(pwd | md5sum)"
fi

printf "${config_home}/vim/sessions/${SUM}"
