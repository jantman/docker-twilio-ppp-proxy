#!/bin/bash -e
PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"

echo "ppp ip-up script called for ${PPP_IFACE} (local=${PPP_LOCAL} remote=${PPP_REMOTE} DNS=${DNS1} ${DNS2})"

echo "removing current nameserver from /etc/resolv.conf"
sed -i '/^nameserver/ d' /etc/resolv.conf

echo "adding $DNS1 and $DNS2 to /etc/resolv.conf"
echo -e "nameserver $DNS1\nnameserver $DNS2" >> /etc/resolv.conf

# replace current default route with via $PPP_REMOTE dev $PPP_IFACE
echo "Removing default route..."
ip route del default
echo "Adding new default route via $PPP_REMOTE dev $PPP_IFACE"
ip route add default via $PPP_REMOTE dev $PPP_IFACE

echo "Verifying with: ping -I $PPP_IFACE -c 3 api.twilio.com"
ping -I $PPP_IFACE -c 3 api.twilio.com

echo "Running tinyproxy..." >> /dev/tty/0
/etc/init.d/tinyproxy start
