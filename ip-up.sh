#!/bin/bash -e
PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"

echo "ppp ip-up script called for ${PPP_IFACE} (DNS1=${DNS1} DNS2=${DNS2} ip-up.sh $1 $2 $3 $4 $5)" >> /var/log/twilio-ppp

echo "removing current nameserver from /etc/resolv.conf" >> /var/log/twilio-ppp
sed -i '/^nameserver/ d' /etc/resolv.conf

echo "adding $DNS1 and $DNS2 to /etc/resolv.conf" >> /var/log/twilio-ppp
echo -e "nameserver $DNS1\nnameserver $DNS2" >> /etc/resolv.conf

# replace current default route with via $PPP_REMOTE dev $PPP_IFACE
echo "Removing default route..." >> /var/log/twilio-ppp
ip route del default
echo "Adding new default route via $PPP_REMOTE dev $PPP_IFACE" >> /var/log/twilio-ppp
ip route add default via $PPP_REMOTE dev $PPP_IFACE

echo "Verifying with: ping -I $PPP_IFACE -c 3 api.twilio.com" >> /var/log/twilio-ppp
ping -I $PPP_IFACE -c 3 api.twilio.com

echo "Running tinyproxy..." >> /var/log/twilio-ppp
/etc/init.d/tinyproxy start
