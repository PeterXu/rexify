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


todo_docker_svc() 
{
    [ $# -lt 3 ] && exit 1
    local fyml="$1"; shift
    local svc="$1"; shift
    local action="$*"

    local RSUDO=n
    local RTODO=y
    echo "=========================="
    echo "[$fyml - $svc] "
    local yml="~/.dockerfile/yaml/$fyml"
    local cmd="docker-compose -f $yml $action $svc"
    [ "$svc" = "all" ] && cmd="docker-compose -f $yml $action"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_peer_probe() 
{
    local RSUDO=n
    local RTODO=y

    local cmd container curhost gluster_hosts 
    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    gluster_hosts="hf-gluster-02 hf-gluster-03 hf-gluster-04 hf-gluster-05"

    cmd="docker exec $container gluster peer status"
    rex -G $curhost Service:manual:do --by=run --cmd="$cmd"

    for host in $gluster_hosts; do
        cmd="docker exec $container gluster peer probe $host"
        rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
    done

    cmd="docker exec $container gluster peer status"
    rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
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
    #next "todo_clone"
    #next "todo_update"
    #next "todo_docker_svc swarmagent-fig.yml docker-proxy up -d"
    #next "todo_docker_svc swarmagent-fig.yml swarm-agent-consul rm -f"
    #next "todo_docker_svc glusterd-fig.yml glusterd_data up -d"
    #next "todo_docker_svc glusterd-fig.yml glusterd up -d"

    #next "todo_peer_probe"

    echo
}

do_test
exit 0
