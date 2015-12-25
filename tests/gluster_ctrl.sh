
todo_fdisk() 
{
    local sdx label mpoint
    local RSUDO=y RTODO=y
    echo "=========================="
    echo "[fdisk] for sdb"
    sdx="sdb"
    label="sdx_label1"
    mpoint="/mnt/brick1"
    rex -G $grp Service:fdisk:do --mountpoint="$mpoint" --ondisk=$sdx --fstype=ext4 --label="$label"

    echo "[fdisk] for sdc"
    read ch

    sdx="sdc"
    label="sdx_label2"
    mpoint="/mnt/brick2"
    rex -G $grp Service:fdisk:do --mountpoint="$mpoint" --ondisk=$sdx --fstype=ext4 --label="$label"
}

todo_peer_probe() 
{
    local RSUDO=n RTODO=y
    local cmd container curhost gluster_hosts 
    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    gluster_hosts="hf-gluster-02 hf-gluster-03 hf-gluster-04 hf-gluster-05"

    cmd="docker exec $container gluster peer status"
    rex -G $curhost Service:manual:do --by=run --cmd="$cmd"

    for host in $gluster_hosts; do
        cmd="docker exec $container gluster peer probe $host"
        rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
    done

    cmd="docker exec $container gluster peer status"
    rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
}

todo_create_vol() 
{
    local RSUDO=n RTODO=y
    local name cmd mount container curhost gluster_hosts
    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    gluster_hosts="hf-gluster-01 hf-gluster-02 hf-gluster-03 hf-gluster-04 hf-gluster-05"

    vol="dist_disp_vol"
    cmd="docker exec $container gluster volume create $vol disperse 5 redundancy 2"

    mount="/mnt/brick1/data"
    for host in $gluster_hosts; do
        cmd="$cmd $host:$mount"
    done
    echo $cmd;

    mount="/mnt/brick2/data"
    for host in $gluster_hosts; do
        cmd="$cmd $host:$mount"
    done
    echo $cmd;
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd"
}

todo_set_vol() 
{
    local container curhost vol cmd prop
    container="yaml_glusterd_1"
    curhost="hf-gluster-01"
    vol="dist_disp_vol"
    cmd="docker exec $container gluster volume set $vol"

    prop="client.event-threads 4"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
    prop="server.event-threads 4"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
    prop="cluster.lookup-optimize on"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
    prop="performance.readdir-ahead on"
    echo "$cmd $prop"
    #rex -G $curhost Service:manual:do --by=run --cmd="$cmd $prop"
}

