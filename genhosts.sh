#!/bin/bash

source $ZBASH

cfg_hosts() {
    mapset hosts "bogon1" "192.168.175.131"
    mapset hosts "bogon2" "192.168.175.132"
}


gen_hosts() {
    [ $# -ne 1 ] && return 1
    local etc_hosts="$1"
    local etc_key="## custom hosts"
    local hosts=$(mapkey hosts)

    echo "" > $etc_hosts
    echo "$etc_key" >> $etc_hosts
    for h in $hosts; do
        echo "$(mapget hosts $h)  $h" >> $etc_hosts
    done
}


if [ $# -eq 1 ]; then
    cfg_hosts
    gen_hosts "$1"
fi

exit 0
