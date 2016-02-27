[ $# -ne 2 ] && echo "[usage] $0 hostname ipaddr" && exit 1

## step1: set hostname
host="$1"
echo "[*] set hostname: <$host>"
sed -in "s/^127.0.1.1.*/127.0.1.1    $host/" /etc/hosts
cat <<EOF > /etc/hostname
$host
EOF


## step2: set ip address
eth="eth0"
dns="10.11.210.253"
[ ${#2} -lt 4 ] && echo "invalid ipaddr" && exit 1
ipaddr="$2"
OFS="$IFS" && IFS="." && ips=($ipaddr) && IFS="$OFS"
ippre="${ips[0]}.${ips[1]}.${ips[2]}"

echo "[*] set <$eth> ip: <$ipaddr>, dns: <$dns>"
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $eth
iface $eth inet static
address $ipaddr
netmask 255.255.255.0
network ${ippre}.0
broadcast ${ippre}.255
gateway ${ippre}.254

# dns-* options are implemented by the resolvconf package, if installed
dns-nameservers $dns 202.102.192.68
dns-search sportsdata.cn
EOF

echo
