set -e
sudo config interface startup Ethernet0
sudo config interface startup Ethernet4
sudo config interface ip add Ethernet0 10.${N}.1.1/24
sudo config interface ip add Ethernet4 10.${N}.0.0/31
if [ "$(redis-cli -n 4 exists 'LOOPBACK_INTERFACE|Loopback0')" = 0 ]; then
    sudo config loopback add Loopback0
fi
sudo config interface ip add Loopback0 10.${N}.255.1/32
sudo config save -y
