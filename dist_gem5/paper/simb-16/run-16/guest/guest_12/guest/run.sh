set -x
export HOME=/root
export LANG=en_US
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
modprobe e1000
ip link show
ip link set dev eth0 address 00:90:00:00:00:14
ip link set dev eth0 up
ip addr add 192.168.0.14/24 dev eth0
echo "Hello from 12 of 16"
echo "run iperf UDP server"
iperf -s -u -P 1
sleep 5
