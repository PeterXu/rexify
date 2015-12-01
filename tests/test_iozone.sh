#!/usr/bin/env bash

kind="dfs"
[ "$LOCAL" = "1" ] && kind="local"


volname="dist_replica_vol"
if [ "$kind" = "dfs" ]; then
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
    [ ! -d $voldata ] && exit 1

    local result="/tmp/iozone_test1_dist_replica_rw_xls.xls"
    local log="/tmp/iozone_test1_dist_replica_rw_log.xls"
    local tfile="$voldata/iozonetest"
    iozone -Rb $result -n 128m -g 1G -i 0 -i 1 -i 2 -r 4K -r 16K -r 64K -r 128K -f $tfile | tee $log &
}

# no disk cache: -I
do_test2() {
    [ ! -d $voldata ] && exit 1

    local result="/tmp/iozone_test2_dist_replica_rw_xls.xls"
    local log="/tmp/iozone_test2_dist_replica_rw_log.xls"
    local tfile="$voldata/iozonetest"
    iozone -Rb $result -n 128m -g 1G -i 0 -i 1 -i 2 -r 4K -r 16K -r 64K -r 128K -I -f $tfile | tee $log &
}

# small files
do_test3() {
    [ ! -d $voldata ] && exit 1

    local small="/tmp/file38k.txt"
    dd if=/dev/zero of=$small bs=38K count=1
    sleep 2

    time for i in `seq 1 1024`; do
        dd if=$small of=$voldata/hello.$i bs=4k count=10 
    done
    sleep 5

    time for i in `seq 1 5000`; do
        dd if=$small of=$voldata/hello.$i bs=4k count=10 
    done
    sleep 5

    time for i in `seq 1 10000`; do
        dd if=$small of=$voldata/hello.$i bs=4k count=10 
    done
    sleep 2
}



case "$1" in
    prepare) do_prepare;;
    test1) do_test1;;
    test2) do_test2;;
    test3) do_test3 >/tmp/iozone_test3_log.txt 2>&1;;
    *) echo "usage: $0 prepare|test1|test2";;
esac

exit 0

