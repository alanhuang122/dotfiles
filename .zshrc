# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/alan/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
autoload -Uz cdr add-zsh-hook
add-zsh-hook -Uz chpwd chpwd_recent_dirs

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "${terminfo[kdch1]}" delete-char
bindkey "^[OC" forward-word
bindkey "^[OD" backward-word

PROMPT='[%D{%H:%M:%S}] [%n@%m] %1~ %(!.#.$) '
TMOUT=1
TRAPALRM () {
    zle reset-prompt
}

alias sudo='sudo '

alias ls='ls -F --color=always'
alias sl='ls'
alias s='ls'
alias l='ls'
alias cls='clear'

alias xxd='xxd -g 1'

alias python='python3'
alias pip='pip3'


export GPG_TTY=$(tty)
alias config='git --git-dir=$HOME/.cfg --work-tree=$HOME'

if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
    tmux attach-session -t $HOST || tmux new-session -s $HOST
fi

export LD_LIBRARY_PATH=/usr/local/lib
export EDITOR=vim
export PYTHONSTARTUP=~/.pythonrc
export PATH=$HOME/.local/bin:$PATH

sc () {
    local PORT;
    if [ -n "${2+1}" ]; then
        PORT=$2
    else
        PORT=443
    fi
    openssl s_client -connect $1:$PORT -showcerts -status < /dev/null 2> /dev/null | grep "Verify return code: 21" > /dev/null
    if [[ $? -ne 0 ]]; then # string not found
        openssl s_client -connect $1:$PORT -showcerts -status
    else
        echo "retrieving intermediate"
        local AIA
        AIA=$(openssl s_client -connect $1:$PORT -showcerts -status < /dev/null 2> /dev/null | openssl x509 -noout -text | grep -Po "CA Issuers - URI:\K.*")
        openssl s_client -connect $1:$PORT -showcerts -status -CAfile =(curl $AIA | openssl x509 -inform der)
    fi
}

scsni () {
    local PORT;
    if [ -n "${2+1}" ]; then
        PORT=$2
    elseb
        PORT=443
    fi
    openssl s_client -connect $1:$PORT -showcerts -status -servername $1 < /dev/null 2> /dev/null | grep "Verify return code: 21" > /dev/null
    if [[ $? -ne 0 ]]; then # string not found
        openssl s_client -connect $1:$PORT -showcerts -status -servername $1
    else
        local AIA
        AIA=$(openssl s_client -connect $1:$PORT -servername $1 -showcerts -status < /dev/null 2> /dev/null | openssl x509 -noout -text | grep -Po "CA Issuers - URI:\K.*")
        openssl s_client -connect $1:$PORT -servername $1 -showcerts -status -CAfile =(curl $AIA | openssl x509 -inform der)
    fi
}

certkey () {
    local EXIT=0;
    if [ -n "${1+1}" ] && [ -n "${2+1}" ]; then
        openssl x509 -in $1 -noout 2> /dev/null;
        if [[ $? -ne 0 ]]; then
            printf "cert file invalid\n";
            EXIT=1;
        fi
        openssl rsa -in $2 -noout 2> /dev/null;
        if [[ $? -ne 0 ]]; then
            printf "key file invalid\n";
            EXIT=1;
        fi
        if [[ $EXIT -ne 0 ]]; then
            return;
        fi
        diff =(openssl x509 -in $1 -pubkey -noout) =(openssl rsa -in $2 -pubout 2> /dev/null) > /dev/null
        if [[ $? -ne 0 ]]; then
            printf "key does not match cert\n";
        else
            printf "key and cert match\n";
        fi
    else
        printf "invalid parameters\n";
    fi
}

cert () {
    openssl x509 -in $1 -noout -text
}

set -o noclobber
