#!/usr/bin/env bash

# usage: 
#       RUSER=.. RPASS=.. RTNUM=1
#       $0 group

[ $# -ne 1 ] && echo "$0 group" && exit 1
grp="$1"
ruser="$RUSER"
[ "$grp" = "" -o "$ruser" = "" ] && echo "RUSER=?" && exit 1
[ "$RTNUM" != "" ] && opts="-t $RTNUM" || opts="-t 1"

next() 
{
    export RSUDO=""
    export RTODO=""
    [ $# -ne 1 ] && exit 1
    echo "/////////////////////////////"
    printf "\n\nTo continue <$1>(y/n): "
    local ch=""
    read ch
    [ "$ch" != "y" ] && return 1
    eval "$1"
}

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
    local cmd="pip install docker-compose"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_clone() 
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[pull dockerfile]"
    local uri="https://github.com/peterxu/dockerfile.git"
    local cmd="rm -rf ~/.dockerfile; git clone $uri ~/.dockerfile"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_chown() 
{
    [ "$__chown_dir" = "" ] && return 1

    local RSUDO=y
    local RTODO=y
    echo "=========================="
    echo "[chown <$__chown_dir>]"
    cmd="chown -R \$RUSER:\$RUSER $__chown_dir"
    rex -G $grp $opts Service:fperm:do --fdir="$__chown_dir"
    __chown_dir=""
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

todo_fdisk() 
{
    local sdx label mpoint
    local RSUDO=y
    local RTODO=y
    echo "=========================="
    echo "[fdisk] for sdb"
    sdx="sdb"
    label="sdx_label1"
    mpoint="/mnt/brick1"
    rex -G $grp Service:fdisk:do --mountpoint="$mpoint" --ondisk=$sdx --fstype=ext4 --label="$label"

    echo "[fdisk] for sdc"
    read ch

    sdx="sdc"
    label="sdx_label2"
    mpoint="/mnt/brick2"
    rex -G $grp Service:fdisk:do --mountpoint="$mpoint" --ondisk=$sdx --fstype=ext4 --label="$label"
}

todo_docker_proxy() 
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[docker-proxy] "
    local yml="swarmagent-fig.yml"
    local svc="docker-proxy"
    local cmd="cd ~/.dockerfile/yaml && docker-compose -f $yml up -d $svc"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_swarm_agent()
{
    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[swarm-agent] "
    local yml="swarmagent-fig.yml"
    local svc="swarm-agent-consul"
    local cmd="cd ~/.dockerfile/yaml && docker-compose -f $yml up -d $svc"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"

}


##=========================
##=========================
##=========================

do_prepare() 
{
    next "todo_base"
    next "todo_clone"
    __chown_dir="~/.dockerfile" && next "todo_chown"
    next "todo_update"
}

do_test() 
{
    next "todo_clone"
}

do_test
exit 0
