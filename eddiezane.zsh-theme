PROMPT='%{$FG[207]%}%2~%{$fg_bold[white]%}$(git_prompt_info)%{$fg_bold[grey]%}%{$reset_color%} '
RPROMPT='%{$FG[207]%}%(1j.[%j].)$(rbenv_check)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[white]%} ]"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ☂"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ☀"
