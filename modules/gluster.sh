cname="glusterfs";
image="xdocker.host:5000/glusterfs";

_is_started() {
    docker ps $* --filter="name=$cname" | grep $cname >/dev/null 2>&1;
}

do_start() {
    docker images | grep "$image" >/dev/null 2>&1;
    if [ $? -ne 0 ]; then
        docker pull $image:latest;
        docker images | grep "$image" >/dev/null 2>&1;
        [ $? -ne 0 ] && echo "[ERROR] failed to pull $image!" && exit 1;
    fi

    _is_started;
    if [ $? -ne 0 ]; then
        _is_started "-a" && docker rm $cname;

        opts="--name=$cname --net=host --privileged=true";
        opts="$opts -v /var/log/glusterfs:/var/lib/glusterfs/var/log/glusterfs";
        opts="$opts -v /mnt/brick1:/mnt/brick1";
        docker run -d $opts $image:latest;

        _is_started;
        [ $? -ne 0 ] && echo "[ERROR] fail to run $cname!" && exit 1;
        echo "[INFO] $cname started success!";
    else
        echo "[WARN] $cname has been started!";
    fi
}
do_stop() {
    _is_started;
    if [ $? -eq 0 ]; then
        docker stop $cname;
        echo "[INFO] $cname stopped success!";
    else
        echo "[WARN] $cname not running!";
    fi
}
do_restart() {
    _is_started "-a";
    if [ $? -eq 0 ]; then
        docker restart $cname;
        echo "[INFO] $cname restarted success!";
    else
        echo "[WARN] $cname not existed!";
    fi
}
do_check() {
    docker images | grep "$image" >/dev/null 2>&1;
    [ $? -ne 0 ] && echo "[WARN] $image not existed!" && exit 1;
    _is_started && echo "[INFO] $cname running!" || echo "[WARN] $cname not started!";
}
do_probe() {
    _is_started;
    if [ $? -ne 0 ]; then
        echo "[ERROR] $cname not running!";
        exit 1;
    fi
    
    local nodes="$*";
    for node in $nodes; do
        echo "[*$node*]=>  ";
        docker exec $cname /var/lib/glusterfs/sbin/gluster peer probe $node;
        printf "\t";
    done
    #docker exec $cname /var/lib/glusterfs/sbin/gluster peer status;
}


