#!/usr/bin/env bash

[ $# -ne 1 ] && exit 1
grp="$1"
ruser="$RUSER"
[ "$grp" = "" -o "$ruser" = "" ] && exit 1
opts="-t 1"

todo1() 
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

todo2() 
{
    local RSUDO=n
    local RTODO=y

    echo "=========================="
    echo "[pull dockerfile]"
    cmd="git clone https://github.com/peterxu/docker.git ~/.dockerfile"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo1

echo "/////////////////////////////"
todo2

exit 0
