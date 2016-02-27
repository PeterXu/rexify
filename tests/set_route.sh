#!/bin/bash

[ $# -ne 2 ] && echo "[usage] $0 ip0 ip1" && exit 1

## eth0
ip0="$1"
[ ${#ip0} -lt 4 ] && echo "invalid ipaddr: $ip0" && exit 1
OFS="$IFS" && IFS="." && ips=($ip0) && IFS="$OFS"
ip0pre="${ips[0]}.${ips[1]}.${ips[2]}"

## eth1
ip1="$2"
[ ${#ip1} -lt 4 ] && echo "invalid ipaddr: $ip1" && exit 1
OFS="$IFS" && IFS="." && ips=($ip1) && IFS="$OFS"
ip1pre="${ips[0]}.${ips[1]}.${ips[2]}"

cat <<EOF > /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

## for eth0
ip route flush table eth0-default
ip route add default via ${ip0pre}.254 dev eth0 src ${ip0} table eth0-default
ip rule add from ${ip0} table eth0-default

## for eth1
ip route flush table eth1-default
ip route add default via ${ip1pre}.254 dev eth1 src ${ip1} table eth1-default
ip rule add from ${ip1} table eth1-default


exit 0
EOF


exit 0
