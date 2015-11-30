#!/usr/bin/env bash

volname="dist_replica_vol"
voldata="/mnt/${volname}_data"

do_prepare() {
    apt-get install -y sysstat

    mkdir -p $voldata
    umount $voldata
    /var/lib/glusterfs/rootfs/sbin/mount.glusterfs bogon3:/$volname $voldata
}

do_test1() {
    cd $voldata
    dd if=/dev/zero of=file1 bs=64K count=4096 &
    dd if=/dev/zero of=file2 bs=64K count=4096 &
    dd if=/dev/zero of=file3 bs=64K count=4096 &
    dd if=/dev/zero of=file4 bs=64K count=4096 &
    dd if=/dev/zero of=file5 bs=64K count=4096 &

    iostat 5
}

do_test2() {
    cd $voldata
    dd if=file1 of=/dev/null bs=64K count=4096 & 
    iostat
}

case "$1" in
    prepare) do_prepare;;
    test1) do_test1;;
    test2) do_test2;;
    *) echo "usage: $0 prepare|test1|test2";;
esac

exit 0
