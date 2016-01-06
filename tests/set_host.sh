[ $# -ne 2 ] && echo "[usage] $0 hostname ipaddr" && exit 1

host="$1"
echo "[*] set hostname: <$host>"
sed -in "s/^127.0.1.1.*/127.0.1.1    $host/" /etc/hosts

cat <<EOF > /etc/hostname
$host
EOF


if [ ${#2} -ge 4 ]; then
ipaddr="$2"
else
ipaddr="10.11.200.$2"
fi
OFS="$IFS" && IFS="." && ips=($ipaddr) && IFS="$OFS"
ippre="${ips[0]}.${ips[1]}.${ips[2]}"

echo "[*] set ipaddr: <$ipaddr>"
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address $ipaddr
netmask 255.255.255.0
network ${ippre}.0
broadcast ${ippre}.255
gateway ${ippre}.254

# dns-* options are implemented by the resolvconf package, if installed
dns-nameservers 10.11.40.5 202.102.192.68
dns-search sportsdata.cn
EOF

echo "[*] set ok!"
echo
