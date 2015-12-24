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
    local uri="http://lark.io:10080/itools/dockerfile.git"
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
    cmd="cd ~/.dockerfile && git checkout . && git pull"
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

todo_create_vol() 
{
    local RSUDO=n
    local RTODO=y

    local name cmd mount container curhost gluster_hosts

    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    gluster_hosts="hf-gluster-01 hf-gluster-02 hf-gluster-03 hf-gluster-04 hf-gluster-05"

    vol="dist_disp_vol"
    cmd="docker exec $container gluster volume create $vol disperse 5 redundancy 2"

    mount="/mnt/brick1/data"
    for host in $gluster_hosts; do
        cmd="$cmd $host:$mount"
    done
    echo $cmd;

    mount="/mnt/brick2/data"
    for host in $gluster_hosts; do
        cmd="$cmd $host:$mount"
    done
    echo $cmd;
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
}

todo_set_vol() {
    local container curhost vol cmd prop
    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    vol="dist_disp_vol"
    cmd="docker exec $container gluster volume set $vol"

    prop="client.event-threads 4"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
    prop="server.event-threads 4"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"

    prop="cluster.lookup-optimize on"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
    prop="performance.readdir-ahead on"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
}


##=========================
##=========================
##=========================

do_prepare() 
{
    next "todo_base"
    next "todo_clone"
    #__chown_dir="~/.dockerfile" && next "todo_chown"
    #next "todo_update"
}

do_swarm() 
{
    next "todo_docker_svc swarmagent-fig.yml all pull"

    local RSUDO=n
    local RTODO=y
    local cmd="host=\$(hostname).sportsdata.cn; sed -in \"s/127.0.0.1/\$host/\" ~/.dockerfile/yaml/swarmagent-fig.yml"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"

    next "todo_docker_svc swarmagent-fig.yml all up -d"
}

do_gluster() 
{
    next "todo_docker_svc glusterd-fig.yml all pull"
    #next "todo_docker_svc glusterd-fig.yml all stop"
    #next "todo_docker_svc glusterd-fig.yml all rm -f"
    #next "todo_docker_svc glusterd-fig.yml glusterd_data up -d"
    #next "todo_docker_svc glusterd-fig.yml glusterd up -d"
    next "todo_docker_svc glusterd-fig.yml all up -d"
}

do_soccerdojo()
{
    next "todo_docker_svc soccerdojo-fig.yml all pull"

    local RSUDO=n
    local RTODO=y
    local cmd="host=\$(hostname).sportsdata.cn; sed -in \"s/DB_HOST=db_host/DB_HOST=\$host/\" ~/.dockerfile/yaml/swarmagent-fig.yml"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"

    next "todo_docker_svc soccerdojo-fig.yml all up -d"
    echo
}


##=========================
##=========================
##=========================

do_test() 
{
    echo
}

do_test
