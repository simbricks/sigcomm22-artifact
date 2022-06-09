set -x
export HOME=/root
export LANG=en_US
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
modprobe e1000
ip link show
ip link set dev eth0 address 00:90:00:00:00:05
ip link set dev eth0 up
ip addr add 192.168.0.5/24 dev eth0
echo "Hello from 3 of 8"
sleep 1
iperf -c 192.168.0.4 -i 1 -u -b 1000m
sleep 5
