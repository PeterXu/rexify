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


##====================================================
##====================================================
##====================================================

do_base() 
{ 
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

do_chown() 
{
    __chown_dir="~/.dockerfile" && next "todo_chown";
}

do_update() 
{
    local msg="pull dockerfile"
    local cmd="cd ~/.dockerfile && git checkout . && git pull"
    next "todo_man \"$msg\" \"$cmd\""
}

# mount for soccerdojo/portal/portalpro/laurels nodes
do_mount() 
{
    local msg="mount gluster disk"
    local cmd="mount -a"
    next "todo_man_sudo \"$msg\" \"$cmd\""
}



##====================================================
##====================================================
##====================================================

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

# pull => up -d
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

# stop + rm -f
do_docker_remove()
{
    [ $# -ne 1 ] && exit 1
    local fyml="$1"
    local yml="~/.dockerfile/yaml/$fyml"
    local cmd="docker-compose -f $yml stop; docker-compose -f $yml rm -f"
    next "todo_man \"$msg\" \"$cmd\""
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

do_gluster_client()
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
    local host="10.11.210.134"
    local mnt="$host:/dist_repl_vol /mnt/nshare glusterfs defaults,_netdev 0 0"
    local cmd="mkdir -p /mnt/nshare; mount | grep \"/mnt/nshare\" && exit 0"
    cmd="$cmd; sed -in /glusterfs/d /etc/fstab; echo \"$mnt\" >> /etc/fstab; mount -a"
    next "todo_man_sudo \"$msg\" \"$cmd\""

    msg="add <mount -a> to /etc/rc.local"
    echo "[WARN] =======> require: $msg"
    cmd="sed -in '/^mount -a/d' /etc/rc.local; sed -in '/^exit 0/d' /etc/rc.local"
    cmd="$cmd; echo 'mount -a' >> /etc/rc.local; echo 'exit 0' >> /etc/rc.local"
    next "todo_man_sudo \"$msg\" \"$cmd\""
}


#=========================================================
#=========================================================
#=========================================================

do_upload_cfg()
{
    [ $# -ne 3 ] && return
    local msg="[$1]" cmd="$1"
    todo_man_sudo  "$msg" "$cmd"

    local RSUDO=y RTODO=y
    local src="$2" dst="$3"
    rex -G $grp $opts Service:upload:do --src="$src" --dst="$dst"
}

do_portal_cfg()
{
    local cmd="mkdir /etc/portal"
    local src="files/etc/portal-config.properties"
    local dst="/etc/portal/config.properties"
    do_upload_cfg "$cmd" "$src" "$dst"
}

do_portalpro_cfg()
{
    local cmd="mkdir /etc/portalpro"
    local src="files/etc/portalpro-config.properties"
    local dst="/etc/portalpro/config.properties"
    do_upload_cfg "$cmd" "$src" "$dst"
}

# both laurels and portalpro in the same servers
do_laurels_cfg()
{
    local cmd="mkdir /etc/laurels"
    local src="files/etc/laurels-config.properties"
    local dst="/etc/laurels/config.properties"
    do_upload_cfg "$cmd" "$src" "$dst"
}

