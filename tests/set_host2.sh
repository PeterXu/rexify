#!/bin/bash

[ $# -ne 3 ] && echo "[usage] $0 hostname ip0 ip1" && exit 1

## step1: set hostname
host="$1"
echo "[*] set hostname: <$host>"
sed -in "s/^127.0.1.1.*/127.0.1.1    $host/" /etc/hosts
cat <<EOF > /etc/hostname
$host
EOF


## step2: set ip address
dns="10.11.210.253"

## eth0
ip0="$2"
[ ${#ip0} -lt 4 ] && echo "invalid ipaddr: $ip0" && exit 1
OFS="$IFS" && IFS="." && ips=($ip0) && IFS="$OFS"
ip0pre="${ips[0]}.${ips[1]}.${ips[2]}"

## eth1
ip1="$3"
[ ${#ip1} -lt 4 ] && echo "invalid ipaddr: $ip1" && exit 1
OFS="$IFS" && IFS="." && ips=($ip1) && IFS="$OFS"
ip1pre="${ips[0]}.${ips[1]}.${ips[2]}"


echo "[*] set ip: <$ip0 - $ip1>, dns: <$dns>"
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address $ip0
netmask 255.255.255.0
network ${ip0pre}.0
broadcast ${ip0pre}.255
gateway ${ip0pre}.254

auto eth1
iface eth1 inet static
address $ip1
netmask 255.255.255.0
network ${ip1pre}.0
broadcast ${ip1pre}.255
#gateway ${ip1pre}.254

# dns-* options are implemented by the resolvconf package, if installed
dns-nameservers $dns 202.102.192.68
dns-search sportsdata.cn
EOF

echo
