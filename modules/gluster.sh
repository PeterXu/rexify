cname="glusterfs";      # exec container name
dname="${cname}_data";  # data container name
image="xdocker.host:5000/glusterfs";


_check0_exit() {
    local err=$?; [ $err -eq 0 ] && echo "$*" && exit 0;
}
_check1_exit() {
    local err=$?; [ $err -ne 0 ] && echo "$*" && exit 1;
}
_is_exist() { # check container
    local name="$1"; shift;
    docker ps $* --filter="name=$name" | grep "$name" >/dev/null 2>&1;
}
_image_exist() { # pull and check image
    docker images | grep "$image" >/dev/null 2>&1;
}
_data_container() { # data container
    _is_exist "$dname" "-a" && return 0;

    local opts="--name=${dname}";
    opts="$opts -v /var/log/glusterfs:/var/lib/glusterfs/var/log/glusterfs";   # persistence
    opts="$opts -v /var/lib/glusterd:/var/lib/glusterfs/var/lib/glusterd";    # persistence
    opts="$opts -v /mnt/brick1:/mnt/brick1";                # use real volume
    docker run $opts $image:latest echo;                    # just start once.

    _is_exist "$dname" "-a";
}

do_pre() {
    docker pull $image:latest;
    _image_exist;
    _check1_exit "[ERROR] no image => $image!";
}
do_start() {
    _image_exist;
    _check1_exit "[ERROR] no image => $image!";

    _data_container;
    _check1_exit "[ERROR] fail to create data container => $dname!";

    _is_exist "$cname";
    _check0_exit "[WARN] $cname has been started!";

    _is_exist "$cname" "-a" && docker rm $cname;

    local opts="--name=$cname --net=host --privileged=true";
    opts="$opts --volumes-from $dname"
    docker run -d $opts $image:latest;

    _is_exist "$cname" && echo "[INFO] $cname started success!" || echo "[ERROR] fail to run $cname!";
}
do_stop() {
    _is_exist "$cname";
    _check1_exit "[WARN] $cname not running!";

    docker stop $cname;
    echo "[INFO] $cname stopped success!";
}
do_restart() {
    _is_exist "$cname" "-a";
    _check1_exit "[WARN] $cname not existed!";

    docker restart $cname;
    echo "[INFO] $cname restarted success!";
}
do_clean() {
    do_stop;
    _is_exist "$cname" "-a" && docker rm $cname;
    _is_exist "$dname" "-a" && docker rm $dname;
}
do_status() {
    _is_exist "$cname";
    if [ $? -eq 0 ]; then
        echo "[INFO] $cname running!";
    else
        _is_exist "$cname" "-a";
        if [ $? -eq 0 ]; then
            echo "[WARN] $cname not started!";
        else
            echo "[WARN] $cname not created!";
        fi
    fi
}

# for gluster operation
do_probe() {
    _is_exist "$cname";
    _check1_exit "[ERROR] $cname not running!";
    
    local nodes="$*";
    for node in $nodes; do
        echo "[*$node*]=>  ";
        docker exec $cname gluster peer probe $node;
        printf "\t";
    done
    #docker exec $cname gluster peer status;
}

