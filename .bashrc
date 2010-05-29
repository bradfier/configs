# Applications
export PAGER='vimpager'
export EDITOR='vim'
export BROWSER='fxs'

# History control
export HISTCONTROL="ignoreboth"
export HISTFILESIZE=500000
export HISTIGNORE="cd:..*:no:na:clear:reset:j *:exit:hc:h:-"

# Set prompt
setprompt(){
    # Capture last return code
    local rts=$?

    # Get path with tilde for home
    if [[ "$PWD" == "$HOME" ]]; then
        local dir="~"
    elif [[ "${PWD:0:${#HOME}}" == "$HOME" ]]; then
        local dir="~${PWD:${#HOME}}"
    else
        local dir=$PWD
    fi

    # Truncate path if it's long
    if [[ ${#dir} -gt 19 ]]; then
        local offset=$((${#dir}-18))
        dir="+${dir:$offset:18}"
    fi

    # Path color indicates host
    case "$HOSTNAME" in
        "ayu") local dircol="\[\e[1;35m\]"; ;; # Desktop
        "misuzu") local dircol="\[\e[1;32m\]"; ;; # Laptop
        "izaya") local dircol="\[\e[1;31m\]"; ;; # Server
        *) local dircol="\[\e[1;37m\]"; ;; # Other
    esac

    # Marker char indicates root or user
    [[ $UID -eq 0 ]] && local marker='#' || local marker='$'

    # Marker color indicates successful execution
    [[ $rts -eq 0 ]] && local colormarker="\[\e[1;37m\]$marker" \
                     || local colormarker="\[\e[1;31m\]$marker"

    # Set PS1
    PS1="${dircol}${dir} ${colormarker}\[\e[0;37m\] "

    # Append history to saved file
    history -a
}
PROMPT_COMMAND="setprompt &> /dev/null"

# Check for current bash version
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    shopt -s autocd cdspell
    shopt -s dirspell globstar
fi

# General options
shopt -s cmdhist nocaseglob
shopt -s histappend extglob

# Don't echo ^C
stty -ctlecho

## Bindings in interactive shells
case "$-" in *i*)
    # Remove annoying fc map
    bind -m vi -r v

    # Walk through completions with ^T
    bind "\C-n: menu-complete"

    # Clear screen with ^L
    bind "\C-l: clear-screen"

    # Add pager pipe with <C-w>
    bind '"\C-t":" | $PAGER \C-m"'

    # Background & ignore with <C-b>
    bind '"\C-b":" &> /dev/null &\C-m"'

    # Search
    bind '"\C-w":" | ack "'

    # Display status
    bind '"\C-x":"; ns\C-m"'

    # Reset
    bind '"\C-a":"reset ; clear \C-m"'

    # Clear
    bind '"\C-k":"cd ; clear \C-m"'
    bind '"\C-e":"clear \C-m"'
;; esac;

# Load autojump
if [[ -f /etc/profile.d/autojump.bash ]]; then
    . /etc/profile.d/autojump.bash
fi

# Give ls more colors
if [[ -x /bin/dircolors ]]; then
    eval $(/bin/dircolors ~/.dircolors)
fi

# Complete only directories on cd
complete -d cd

# Aliases
# Ls
alias ls='ls --color=auto -Fh --group-directories-first'
alias ll='ls -lah'
alias no='ls'
alias na='ll'

# Abbreviations
alias prf='export WINEPREFIX=$(pwd)'
alias i='makepkg -fi'
alias a='git add'
alias m='encMount'
alias d='git diff'
alias p='git push origin master'
alias pu='git pull origin master'
alias pd='git push origin'
alias pud='git pull origin'
alias pn='git push'
alias pun='git pull'
alias pg='$PAGER'
alias r='rolldice'
alias v='vim'
alias vv='sudo vim'
alias t='todo'
alias td='todo --database ~/.todo.daily'
alias ts='todo --database ~/.todo.schedule'

# cd abbreviations
alias h='builtin cd'
alias p+='dp +1'
alias p2='dp +2'
alias p3='dp +3'
alias p4='dp +4'
alias -- p-='dp -0'
alias -- p-1='dp -1'
alias -- p-2='dp -2'
alias -- p-3='dp -3'
alias -- p-4='dp -4'
alias -- -='cd -'

# directory up abbreviations
..() { cd "../$@"; }
..2() { cd "../../$@"; }
..3() { cd "../../../$@"; }
..4() { cd "../../../../$@"; }
..5() { cd "../../../../../$@"; }

# Fallback to grep if ack is not found
if [[ ! -x ~/bin/ack ]]; then
    alias ack="grep -i --color=always"
else
    alias ack="command ack -i"
fi

# Unpack programs
if [[ -x '/usr/bin/aunpack' ]]; then
    alias un='aunpack'
else
    alias un='tar xvf'
fi

# Shortcut functions
slide() { feh -FrzZ -D7 $1 & }
x(){ builtin cd ~; exec xinit $@; }
tm() { tmux -2 attach -t $1; }
tmn() { tmux -2 new -s $1 $1; }
yt() { youtube-pl -q $(xclip -o); }

# ls with directory name on top
dls() { ls $@; }

# cd shortcuts
hc() { builtin cd; clear; }
mcd() { mkdir -p "$1" && eval cd "$1"; }
cd() { if [[ -n "$1" ]]; then builtin cd "$1" && dls;
                         else builtin cd && dls; fi; }
,cd() { [[ -n "$1" ]] && builtin cd "$1" || builtin cd; }
ca() { ,cd "$1"; dls -la; }
cn() { ,cd "$1"; dls -a; }

di() { dirs -v; }
po() { if [[ -n "$1" ]]; then popd "$1" 1>/dev/null && dls;
                         else popd 1>/dev/null && dls; fi; }
dp() { pushd "$1" 1>/dev/null && dls; }

# Watch list shortcuts
w()   { ani watch: $@; }
lo()  { ani log: $@; }
li()  { ani list: $@; }
wh()  { ani hist; }
an()  { ani list: +w =anime; }
anh() { ani hist: =anime; }
tn()  { ani list: +w =tv; }
tnh() { ani hist: =tv; }

# Feed shortcuts
fu()  { feed-update > ~/.feeds.update; }
fo()  { cat ~/.feeds.update | while read url; do $BROWSER $url; done; }

# Daemon shortcuts
dr() { for d in $@; do sudo /etc/rc.d/$d restart; done; }
ds() { for d in $@; do sudo /etc/rc.d/$d start; done; }
dt() { for d in $@; do sudo /etc/rc.d/$d stop; done; }

# Local server start and stop
sstart() { ds httpd mysqld; }
sstop()  { dt httpd mysqld; }

# Sync music
syncm() { sudo rsync -vhru --progress /data/music/Anime/ /mnt/iriver/Music/Anime/; }

# Set and jump to marks
ma() {
    mark="$1"
    [[ -n "$2" ]] && dir="$2" || dir=$(pwd)
    eval "MARK_$mark=\$dir"
}

go() {
    mark="$1"
    eval "dir=\$MARK_$mark"

    if [[ -n $dir ]]; then
        cd $dir
    fi;
}

sw() {
    ma1=$1
    ma2=$2

    eval "dir1=\$MARK_$ma1"
    eval "dir2=\$MARK_$ma2"

    if [[ "$PWD" = "$dir1" ]]; then
        go $ma2
    else if [[ "$PWD" = "$dir2" ]]; then
        go $ma1
    else
        go $ma1
    fi;
    fi;
}

got() { go t; }; gon() { go n; }
mt() { ma t; }; mn() { ma n; }
st() { sw t n; }

# Save and load sets of marks
lma() { [[ -n "$1" ]] && source ~/.bashmarks/$1 || source ~/.bashmarks/global; }
sma() { file=$1; shift; for i in $@; do
          eval "echo \"ma $i \$MARK_$i\" >> ~/.bashmarks/$file";
done; }
cma() { :>~/.bashmarks/$1; }

# Load global bashmarks
lma

# Notify command exit status
ns() {
    cmd=$(history 1 | head -n 1 | sed "s|^[^\s]* ||" | sed "s|; ns.*$||")
    status=$?

    [[ $? == 0 ]] && notify-send --always "$cmd" "Successfully finished." \
                  || notify-send --critical "$cmd" "Returned with error code $?"
}

# Wrapper for tvtime
tvtime() {
    sudo modprobe -a saa7134_alsa saa7134
    while [[ ! -e /dev/video0 ]]; do sleep 0.5; done;
    sudo /usr/bin/tvtime
    cp ~/.tvtime/tvtime.xml.orig ~/.tvtime/tvtime.xml
    sudo modprobe -r saa7134_alsa
}

# Commit git -a or path
c() {
    if [[ "$1" == "-i" ]]; then
        shift; git commit -s --interactive $@
    else
        if [[ -n "$@" ]]; then
            git commit -s $@
        else
            git commit -s -a
        fi;
    fi;
}

sa() {
    git status | ack -B 999 --no-color "Untracked"
}

# Root where packages are stored
PACKAGE_ROOT=/mnt/data-5/others/packages

# Download package from abs
absd() {
    abs $1/$2
    cp -R /var/abs/$1/$2 $PACKAGE_ROOT/abs
    builtin cd $PACKAGE_ROOT/abs/$2
}

# Download package from aur
aurd() {
    if wget http://aur.archlinux.org/packages/$1/$1.tar.gz \
             -O $PACKAGE_ROOT/aur/$1.tar.gz;
    then
        builtin cd $PACKAGE_ROOT/aur
        tar xvf $1.tar.gz || return 1
        rm $1.tar.gz
        cd $1
    fi
}

# Make a git package, then show the log
gi() {
    gitdir=$1; shift
    from=$(git --git-dir=src/$gitdir/.git rev-parse HEAD)
    makepkg -fi $@
    git --git-dir=src/$gitdir/.git log --stat $from..HEAD
}

# Go to a package directory
ga() { cd $PACKAGE_ROOT/$1/$2; }

# Flatten function
flat() {
    mkdir ../__flat;
    find . -print0 | xargs -0 -i'{}' cp '{}' ../__flat;
    mv ../__flat/* . && rmdir ../__flat
}

## Map function for bash.
# Courtesy downdiagonal on reddit.
# http://www.reddit.com/r/linux/comments/akt3j
map() {
    local command i rep
    if [ $# -lt 2 ] || [[ ! "$@" =~ :[[:space:]] ]];then
        echo "Invalid syntax." >&2; return 1
    fi
    until [[ $1 =~ : ]]; do
        command="$command $1"; shift
    done
    command="$command ${1%:}"; shift
    for i in "$@"; do
        if [[ $command =~ \{\} ]]; then
            rep="${command//\{\}/\"$i\"}"
            eval "${rep//\\/\\\\}"
        else
            eval "${command//\\/\\\\} \"${i//\\/\\\\}\""
        fi
    done
}
