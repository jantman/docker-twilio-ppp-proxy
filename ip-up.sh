#!/bin/bash -e
PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"

echo "ppp ip-up script called for ${PPP_IFACE} (local=${PPP_LOCAL} remote=${PPP_REMOTE} DNS=${DNS1} ${DNS2})" >> /dev/tty/0

echo "removing current nameserver from /etc/resolv.conf" >> /dev/tty/0
sed -i '/^nameserver/ d' /etc/resolv.conf

echo "adding $DNS1 and $DNS2 to /etc/resolv.conf" >> /dev/tty/0
echo -e "nameserver $DNS1\nnameserver $DNS2" >> /etc/resolv.conf

# replace current default route with via $PPP_REMOTE dev $PPP_IFACE
echo "Removing default route..." >> /dev/tty/0
ip route del default
echo "Adding new default route via $PPP_REMOTE dev $PPP_IFACE" >> /dev/tty/0
ip route add default via $PPP_REMOTE dev $PPP_IFACE

echo "Verifying with: ping -I $PPP_IFACE -c 3 api.twilio.com" >> /dev/tty/0
ping -I $PPP_IFACE -c 3 api.twilio.com

echo "Setting tinyproxy bind address..." >> /dev/tty/0
sed -i "s/#Bind 192.168.0.1/Bind $PPP_LOCAL/" /etc/tinyproxy/tinyproxy.conf

echo "Running tinyproxy..." >> /dev/tty/0
/etc/init.d/tinyproxy start
