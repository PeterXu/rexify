#!/usr/bin/env bash

kind="dfs"
[ "$LOCAL" = "1" ] && kind="local"


volname="dist_replica_vol"
if [ "$kind" = "dfs"]; then
    voldata="/mnt/${volname}_data"
else
    voldata="/mnt/${volname}_local"
fi


do_prepare() {
    apt-get install -y iozone3

    mkdir -p $voldata
    if [ "$kind" = "dfs" ]; then
        umount $voldata
        /var/lib/glusterfs/rootfs/sbin/mount.glusterfs bogon3:/$volname $voldata
    fi
}


# disk cache
do_test1() {
    local result="/tmp/iozone_test1_dist_replica_rw_xls.xls"
    local log="/tmp/iozone_test1_dist_replica_rw_log.xls"
    local tfile="$voldata/iozonetest"
    iozone -Rb $result -n 128m -g 1G -i 0 -i 1 -i 2 -r 4K -r 16K -r 64K -r 128K -f $tfile | tee $log &
}

# no disk cache: -I
do_test2() {
    local result="/tmp/iozone_test2_dist_replica_rw_xls.xls"
    local log="/tmp/iozone_test2_dist_replica_rw_log.xls"
    local tfile="$voldata/iozonetest"
    iozone -Rb $result -n 128m -g 1G -i 0 -i 1 -i 2 -r 4K -r 16K -r 64K -r 128K -I -f $tfile | tee $log &
}

# small files
do_test3() {
    local small="/tmp/file38k.txt"
    dd if=/dev/zero of=$small bs=38K count=1
    sleep 2

    for((i=1;i<=1024;i++)); do
        dd if=$small of=$voldata/hello.$i bs=4k count=10 
        echo "hello.$i was created"
    done
}



case "$1" in
    prepare) do_prepare;;
    test1) do_test1;;
    test2) do_test2;;
    test3) do_test3;;
    *) echo "usage: $0 prepare|test1|test2";;
esac

exit 0

