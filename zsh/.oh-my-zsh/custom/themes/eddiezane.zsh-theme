PROMPT='%{$FG[207]%}$(ssh_check)%2~%{$fg_bold[white]%}$(git_prompt_info)%{$fg_bold[grey]%}%{$fg[yellow]%}$(gs_check)$(gopath_check)%{$reset_color%} '
RPROMPT='%{$FG[207]%}%(1j.[%j].)%{$reset_color%}'
# RPROMPT='%{$FG[207]%}%(1j.[%j].)$(rbenv_check)%{$reset_color%}'

# http://dougblack.io/words/zsh-vi-mode.html
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$FG[207]%}"
    RPROMPT="%{$FG[207]%}%(1j.[%j].)${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}%{$reset_color%}"
    # RPROMPT="%{$FG[207]%}%(1j.[%j].)${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(rbenv_check)%{$reset_color%}"
    zle reset-prompt
}

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[white]%} ]"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ☂"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ☀"
