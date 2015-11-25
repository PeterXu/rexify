#!/bin/bash

source $ZBASH

gen_hosts() 
{
    [ $# -ne 1 ] && return 1
    [ -z "$1" ] && return 1
    [ ! -f server.ini ] && return 1

    local etc_hosts="$1"
    local etc_key="## custom hosts begin"
    echo "" > $etc_hosts
    echo "$etc_key" >> $etc_hosts

    ini-parse server.ini
    local keys=$(ini-secs server.ini)
    for key in $keys; do
        if [[ "$key" =~ "@" ]]; then
            host=$(mapget $key host)
            echo "#-${key:1} = $host" >> $etc_hosts
        else
            host=$(mapget $key host)
            user=$(mapget $key user)
            echo "$host  $key" >> $etc_hosts
        fi
    done
    echo "## custom hosts end" >> $etc_hosts
}

gen_example() 
{
    [ -f ./server.ini ] && return 0
    cat > ./server.ini << EOF
[bogon1]
host = 192.168.175.135
user = peter

[bogon2]
host = 192.168.175.136
user = peter


[@all]
host = bogon1, bogon2
EOF
}


[ $# -eq 1 ] && tmp="$1"
if [ "$tmp" = "help" ]; then
    gen_example
else
    gen_hosts "$tmp"
fi

exit 0
