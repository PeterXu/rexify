#!/bin/bash

for_run() 
{
    [ $# -ne 3 ] && exit 1
    local group="$1" yaml="$2" service="$3"
    [ "$group" = "" -o "$yaml" = "" ] && exit 1

    export RGROUP="$group"
    source tests/run_base_cfg.sh
    source tests/gluster_ctrl.sh

    do_base
    do_clone
    #do_update
    #do_mount
    todo_fdisk

    #do_swarm
    #do_gluster_client
    #do_gluster_mount
    #do_portalpro_cfg
    #do_laurels_cfg

    #do_docker_svc $yaml $service restart
    #do_docker_svc $yaml $service stop
    #do_docker_svc $yaml $service rm -f
    #do_docker_svc $yaml $service pull
    #do_docker_remove $yaml
    #do_docker_svc $yaml $service up -d
}


group="@mon-hf"           && yaml="test"
for_run "$group" "$yaml" "$service"

exit 0
