# Plugins
autoload -U colors && colors
source "${XDG_CONFIG_HOME}/zsh/autocomplete.zsh"
source "${XDG_CONFIG_HOME}/zsh/fzf-marker.plugin.zsh"
source "${XDG_CONFIG_HOME}/zsh/git.zsh"
source "${XDG_CONFIG_HOME}/zsh/history.zsh"
source "${XDG_CONFIG_HOME}/zsh/key-bindings.zsh"

export FZF_MARKER_CONF_DIR="${XDG_CONFIG_HOME}/markers"
export FZF_MARKER_COMMENT_COLOR="$fg[blue]"
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(vim {})+abort'"
export GATSBY_TELEMETRY_DISABLED=1

# Custom ENVs

export PATH=~/.local/bin:~/.cargo/bin:$PATH
export TERM="screen-256color"

# Prompt Theme
setopt PROMPT_SUBST

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
PROMPT='$(git_custom_status)%{$fg[cyan]%}[%~% ]%{$reset_color%}%B$%b '

# Add ellipsis pkg.init support
if [ -f ~/.ellipsis/init.sh ]; then
    . ~/.ellipsis/init.sh
else
    export PATH="$PATH:~/.ellipsis/bin"
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
