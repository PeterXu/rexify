cname="glusterfs";
image="xdocker.host:5000/glusterfs";

do_start() {
    docker images | grep "$image";
    if [ $? -ne 0 ]; then
        docker pull $image:latest;
        docker images | grep "$image" || exit 1;
    fi

    docker ps --filter="name=$cname" | grep $cname;
    if [ $? -ne 0 ]; then
        docker ps -a --filter="name=$cname" | grep $cname && docker rm $cname;
        opts="--name=$cname";
        opts="$opts -v /var/log/glusterfs:/var/lib/glusterfs/var/log/glusterfs";
        opts="$opts -v /mnt/brick1/data:/mnt/brick1/data";
        docker run -d --net=host $opts $image:latest
    fi
}

do_stop() {
    docker ps --filter="name=$cname" | grep $cname && docker stop $cname;
}

do_restart() {
    docker ps --filter="name=$cname" | grep $cname && docker restart $cname;
}

