#!/usr/bin/env bash

mount="/var/lib/glusterfs/rootfs/sbin/mount.glusterfs"
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
        (umount $voldata)
        $mount bogon3:/$volname $voldata
    fi
}


# disk cache: big file
_test() {
    [ ! -d $voldata ] && exit 1

    local idx="$1";
    local min="$2"; # 128m
    local max="$3"; # 1G
    local opt="$4";

    local res="/tmp/iozone_test${idx}_dist_replica_rw_xls.xls"
    local log="/tmp/iozone_test${idx}_dist_replica_rw_log.xls"
    local tfile="$voldata/iozonetest"
    
    iozone -Rb $res -n $min -g $max -i 0 -i 1 -i 2 -r 4K -r 16K -r 64K -r 128K $opt -f $tfile | tee $log &
}

do_test1() { # disk cache : big file
    _test "1" "128m" "1g" "";
}
do_test11() {
    _test "11" "4k" "1m" "";
}
do_test12() {
    _test "12" "2m" "32m" "";
}
do_test2() { # no disk cache: big file
    _test "2" "128m" "1G" "-I";
}
do_test21() { # no disk cache: small file
    _test "21" "4k" "1m" "-I";
}
do_test22() { # no disk cache: small file
    _test "22" "2m" "32m" "-I";
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
    test1|test11|test12) do_$1;;
    test2|test21|test22) do_$1;;
    test3) do_test3 >/tmp/iozone_test3_log.txt 2>&1;;
    *) echo "usage: $0 prepare | test1|test11|test12 | test2|test21|test22";;
esac

exit 0

