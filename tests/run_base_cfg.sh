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
    echo
    echo "/////////////////////////////"
    printf "\n\nTo continue <$1>(y/n): "
    local ch=""
    read ch
    [ "$ch" != "y" ] && return 1
    eval "$1"
}

todo_man_sudo()
{
    [ $# -lt 2 ] && return
    local msg="$1"; shift; local cmd="$*"
    local RSUDO=y RTODO=y
    echo "=========================="
    echo "[$msg]"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_man()
{
    [ $# -lt 2 ] && return
    local msg="$1"; shift; local cmd="$*"
    local RSUDO=n RTODO=y
    echo "=========================="
    echo "[$msg]"
    rex -G $grp $opts Service:manual:do --by=run --cmd="$cmd"
}

todo_base() 
{
    local RSUDO=y RTODO=y

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
do_base() { 
    next "todo_base"; 
}

do_clone() 
{
    local msg="clone dockerfile"
    #local uri="https://github.com/peterxu/dockerfile.git"
    local uri="http://lark.io:10080/itools/dockerfile.git"
    local cmd="rm -rf ~/.dockerfile; git clone $uri ~/.dockerfile"
    next "todo_man \"$msg\" \"$cmd\""
}

todo_chown() 
{
    [ "$__chown_dir" = "" ] && return 1
    local RSUDO=y RTODO=y
    echo "=========================="
    echo "[chown <$__chown_dir>]"
    cmd="chown -R \$RUSER:\$RUSER $__chown_dir"
    rex -G $grp $opts Service:fperm:do --fdir="$__chown_dir"
    __chown_dir=""
}
do_chown() {
    __chown_dir="~/.dockerfile" && next "todo_chown";
}

do_update() 
{
    local msg="pull dockerfile"
    local cmd="cd ~/.dockerfile && git checkout . && git pull"
    next "todo_man \"$msg\" \"$cmd\""
}

source `pwd`/tests/gluster_ctrl.sh

##=========================
##=========================
##=========================

do_docker_svc() 
{
    [ $# -lt 3 ] && exit 1
    local fyml="$1"; shift
    local svc="$1"; shift
    local action="$*"

    local msg="$fyml - $svc"
    local yml="~/.dockerfile/yaml/$fyml"
    local cmd="docker-compose -f $yml $action $svc"
    [ "$svc" = "all" ] && cmd="docker-compose -f $yml $action"
    next "todo_man \"$msg\" \"$cmd\""
}

do_docker_run()
{
    [ $# -ne 3 ] && exit 1
    local yml="$1" msg="$2" cmd="$3" 
    do_docker_svc $yml all pull
    next "todo_man \"$msg\" \"$cmd\""
    do_docker_svc $yml all up -d
    echo
}

do_swarm() 
{
    local yml="swarmagent-fig.yml"
    local msg="replace <127.0.0.1> in $yml"
    local cmd="host=\$(hostname).sportsdata.cn; sed -in \"s/127.0.0.1/\$host/\" ~/.dockerfile/yaml/$yml"
    do_docker_run $yml "$msg" "$cmd"
}

do_gluster() 
{
    local yml="glusterd-fig.yml"
    do_docker_svc $yml all pull
    #do_docker_svc $yml all stop
    #do_docker_svc $yml all rm -f
    #do_docker_svc $yml glusterd_data up -d
    #do_docker_svc $yml glusterd up -d
    do_docker_svc $yml all up -d
}

do_soccerdojo()
{
    local yml="soccerdojo-fig.yml"
    local msg="$yml"
    local cmd="echo"
    do_docker_run $yml "$msg" "$cmd"
}

do_portal()
{
    local yml="portal-fig.yml"
    local msg="$yml"
    local cmd=""

    #cmd="sed -in \"s/127.0.0.1/10.11.200.11/\" /etc/portal/config.properties"
    #cmd="$cmd; docker restart HUP yaml_portal_1"
    #cmd="rm -rf /var/log/portal_tomcat7_log/; docker stop yaml_portal_1"
    #todo_man_sudo  "$msg" "$cmd"

    cmd="echo"
    do_docker_run $yml "$msg" "$cmd"
}

do_portalpro()
{
    local yml="portalpro-fig.yml"
    local msg="$yml"
    local cmd=""

    #cmd="sed -in \"s/127.0.0.1/10.11.200.12/\" /etc/portalpro/config.properties"
    #cmd="$cmd; docker restart yaml_portalpro_1"
    #cmd="rm -rf /var/log/portalpro_tomcat7_log/; docker stop yaml_portalpro_1"
    #todo_man_sudo  "$msg" "$cmd"

    cmd="echo"
    do_docker_run $yml "$msg" "$cmd"
}

