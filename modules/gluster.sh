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

        opts="--name=$cname --net=host";
        opts="$opts -v /var/log/glusterfs:/var/lib/glusterfs/var/log/glusterfs";
        opts="$opts -v /mnt/brick1:/mnt/brick1";
        docker run -d $opts $image:latest;

        _is_started;
        [ $? -ne 0 ] && echo "[ERROR] fail to run $cname!" && exit 1;

        dpath="dist_replica1 stripe_replica1 dist_stripe_replica1";
        for p in $dpath; do
            docker exec $cname mkdir -p /mnt/brick1/$p;
        done
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
        echo "[WARN] $cname not running/existed!";
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

