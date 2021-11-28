#!/bin/bash

echo "interface wlan0" >> /etc/dhcpcd.conf
echo "static ip_address=192.168.1.21/24" >> /etc/dhcpcd.conf
echo "denyinterfaces eth0" >> /etc/dhcpcd.conf
echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=wlan0" > /etc/dnsmasq.conf
echo "    dhcp-range=192.168.1.21,192.168.1.50,255.255.255.0,24h" >> /etc/dnsmasq.conf

FILE=/etc/hostapd/hostapd.conf
if test -f "$FILE"; then
	mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.orig
fi
echo "interface=wlan0" > /etc/hostapd/hostapd.conf
echo bridge=br0 >> /etc/hostapd/hostapd.conf
echo hw_mode=g >> /etc/hostapd/hostapd.conf
echo channel=7 >> /etc/hostapd/hostapd.conf
echo wmm_enabled=0 >> /etc/hostapd/hostapd.conf
echo macaddr_acl=0 >> /etc/hostapd/hostapd.conf
echo auth_algs=1 >> /etc/hostapd/hostapd.conf
echo ignore_broadcast_ssid=0 >> /etc/hostapd/hostapd.conf
echo wpa=2 >> /etc/hostapd/hostapd.conf
echo wpa_key_mgmt=WPA-PSK >> /etc/hostapd/hostapd.conf
echo wpa_pairwise=TKIP >> /etc/hostapd/hostapd.conf
echo rsn_pairwise=CCMP >> /etc/hostapd/hostapd.conf
echo ssid=Raspberry >> /etc/hostapd/hostapd.conf
echo wpa_passphrase=123456789 >> /etc/hostapd/hostapd.conf
sed -i '/#DAEMON_CONF=/c\DAEMON_CONF="/etc/hostapd/hostapd.conf"' /etc/default/hostapd

sed -i '/#net.ipv4.ip_forwarding=1/c\net.ipv4.ip_forwarding=1' /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"
iptables-restore < /etc/iptables.ipv4.nat


brctl addbr br0
brctl addif br0 eth0
brctl addif br0 wlan0
echo "auto br0" >> /etc/network/interfaces
echo "iface br0 inet manual" >> /etc/network/interfaces
echo "bridge_ports eth0 wlan0" >> /etc/network/interfaces
ifconfig eth0 up
ifconfig wlan0 up
ifconfig br0 up
