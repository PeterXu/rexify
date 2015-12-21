#!/usr/bin/env bash

[ $# -ne 1 ] && exit 1
grp="$1"
ruser="$RUSER"
[ "$grp" = "" -o "$ruser" = "" ] && exit 1
opts="-t 1"

todo_base() 
{
    local RSUDO=y
    local RTODO=y

    echo "=========================="
    echo "[sshkey]"
    rex -G $grp Service:sshkey:do

    echo "=========================="
    echo "[apt]"
    rex -G $grp $opts Service:apt:do

    echo "=========================="
    echo "[docker]"
    rex -G $grp $opts Service:docker:do --reload=all

    echo "=========================="
    echo "[pip]"
    rex -G $grp $opts Service:pip:do
    #rex -G $grp Service:hosts:do

    echo "=========================="
    echo "[docker-compose]"
    cmd="pip install docker-compose"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_clone() 
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[pull dockerfile]"
    cmd="git clone https://github.com/peterxu/docker.git ~/.dockerfile"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_update() 
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[pull dockerfile]"
    cmd="cd ~/.dockerfile && git pull"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_chown() 
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[pull dockerfile]"
    cmd="chown -R \$RUSER:\$RUSER ~/.dockerfile"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

next() 
{
    export RSUDO=""
    export RTODO=""
    [ $# -ne 1 ] && exit 1
    echo "/////////////////////////////"
    printf "\n\nTo continue <$1>(y/n): "
    read ch
    [ "$ch" != "y" ] && return 1
    eval "$1"
    return 0
}


next "todo_base"
next "todo_clone"
next "todo_update"

exit 0
