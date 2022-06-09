set -x
export HOME=/root
export LANG=en_US
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
modprobe e1000
ip link show
ip link set dev eth0 address 00:90:00:00:00:03
ip link set dev eth0 up
ip addr add 192.168.0.3/24 dev eth0
echo "Hello from 1 of 16"
sleep 1
iperf -c 192.168.0.2 -i 1 -u -b 1000m
sleep 5
