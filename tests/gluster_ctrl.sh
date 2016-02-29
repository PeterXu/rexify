
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
    return 0

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

    # type1: for replica arbiter
    vol="dist_repl_arbi_vol"
    ip1="10.11.210.131" && ip2="10.11.210.132" && ip3="10.11.210.133" && ip4="10.11.210.134"
    mount="/mnt/brick1/dist_repl_arbi"
    arbiter1="/mnt/brick1/g1_g2_arbiter"
    arbiter2="/mnt/brick1/g3_g4_arbiter"
    cmd="docker exec $container gluster volume create $vol replica 3 arbiter 1"
    cmd="$cmd $ip1:$mount $ip2:$mount $ip3:$arbiter1 $ip3:$mount $ip4:$mount $ip2:$arbiter2"
    echo $cmd;
    echo

    vol="dist_repl_vol"
    mount="/mnt/brick1/dist_repl"
    cmd="docker exec $container gluster volume create $vol replica 2"
    cmd="$cmd $ip1:$mount $ip2:$mount $ip3:$mount $ip4:$mount"
    echo $cmd;
    return;


    # type2: for distribute disperse volume
    curhost="hf-gluster-01"
    gluster_hosts="hf-gluster-01 hf-gluster-02 hf-gluster-03 hf-gluster-04"

    vol="dist_disp_vol"
    cmd="docker exec $container gluster volume create $vol disperse 5 redundancy 2"

    mount="/mnt/brick1/data"
    for host in $gluster_hosts; do
        cmd="$cmd $host:$mount"
    done
    echo $cmd;
    return 0

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

