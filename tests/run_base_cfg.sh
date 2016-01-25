#!/usr/bin/env bash

# usage: 
#       RUSER=.. RPASS=.. RTNUM=1
#       $0 group

[ $# -eq 1 ] && grp="$1" || grp="$RGROUP"
[ "${#grp}" -lt 3 ] && echo "usage: $0 group" && exit 1

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


##====================================================
##====================================================
##====================================================

# 
# usage: $0 yml service action(up -d/start/stop)
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

#
# desc: pull => up -d
# usage: $0 yml msg cmd
do_docker_run()
{
    [ $# -ne 3 ] && exit 1
    local yml="$1" msg="$2" cmd="$3" 
    do_docker_svc $yml all pull
    next "todo_man \"$msg\" \"$cmd\""
    do_docker_svc $yml all up -d
    echo
}

do_stop_rm()
{
    [ $# -ne 1 ] && exit 1
    local yml="$1"
    do_docker_svc $yml all stop
    do_docker_svc $yml all rm -f
}


#=========================================================
#=========================================================
#=========================================================

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

do_gluster_clent()
{
    local msg="config gluster client"
    local cmd="docker pull lark.io/glusterfs:stable"
    cmd="$cmd; docker run --rm -v /var/lib:/root/lib lark.io/glusterfs:stable cp -rf /var/lib/glusterfs /root/lib/"
    next "todo_man \"$msg\" \"$cmd\""

    cmd="mkdir -p /mnt/nshare"
    cmd="$cmd; ln -sf /var/lib/glusterfs/rootfs/sbin/mount.glusterfs /sbin/"
    next "todo_man_sudo \"$msg\" \"$cmd\""
}

do_gluster_mount()
{
    local msg="mount gluster"
    local host="hf-gluster-03.sportsdata.cn"
    local mnt="$host:/dist_disp_vol /mnt/nshare glusterfs defaults,_netdev 0 0"
    local cmd="mkdir -p /mnt/nshare; mount | grep \"/mnt/nshare\" && exit 0"
    cmd="$cmd; sed -in /glusterfs/d /etc/fstab; echo \"$mnt\" >> /etc/fstab; mount -a"
    next "todo_man_sudo \"$msg\" \"$cmd\""
}

# for soccerdojo/portal/portalpro/laurels nodes
do_mount() 
{
    local msg="mount gluster disk"
    local cmd="mount -a"
    next "todo_man_sudo \"$msg\" \"$cmd\""
}

#=========================================================
#=========================================================
#=========================================================

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


#=========================================================
#=========================================================
#=========================================================

do_portal_cfg()
{
    local msg="mkdir /etc/portal"
    local cmd="mkdir /etc/portal"
    todo_man_sudo  "$msg" "$cmd"

    local RSUDO=y RTODO=y
    local src="files/etc/portal-config.properties"
    local dst="/etc/portal/config.properties"
    rex -G $grp $opts Service:upload:do --src="$src" --dst="$dst"
}

do_portalpro_cfg()
{
    local msg="mkdir /etc/portalpro"
    local cmd="mkdir /etc/portalpro"
    todo_man_sudo  "$msg" "$cmd"

    local RSUDO=y RTODO=y
    local src="files/etc/portalpro-config.properties"
    local dst="/etc/portalpro/config.properties"
    rex -G $grp $opts Service:upload:do --src="$src" --dst="$dst"
}

# both laurels and portalpro in the same servers
do_laurels_cfg()
{
    local msg="mkdir /etc/laurels"
    local cmd="mkdir /etc/laurels"
    todo_man_sudo  "$msg" "$cmd"

    local RSUDO=y RTODO=y
    local src="files/etc/laurels-config.properties"
    local dst="/etc/laurels/config.properties"
    rex -G $grp $opts Service:upload:do --src="$src" --dst="$dst"
}

