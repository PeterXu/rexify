#!/bin/bash

source $ZBASH

gen_hosts() {
    [ $# -ne 1 ] && return 1
    [ ! -f server.ini ] && return 1

    local etc_hosts="$1"
    local etc_key="## custom hosts"
    echo "" > $etc_hosts
    echo "$etc_key" >> $etc_hosts

    ini-parse server.ini
    local keys=$(ini-secs server.ini)
    for key in $keys; do
        if [[ "$key" =~ "@" ]]; then
            host=$(mapget $key host)
            echo "#${key:1} = $host" >> $etc_hosts
        else
            host=$(mapget $key host)
            user=$(mapget $key user)
            echo "$host  $key" >> $etc_hosts
        fi
    done
}


[ $# -ne 1 ] && tmp="/tmp/hosts.extra" || tmp="$1"
gen_hosts "$tmp"

exit 0
