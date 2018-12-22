#!/bin/bash

set -o errexit
readonly LOG_FILE="/var/log/twilio-ppp"
exec 1>$LOG_FILE
exec 2>&1
set -o xtrace

PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"

echo "ppp ip-up script called for ${PPP_IFACE} (DNS1=${DNS1} DNS2=${DNS2} ip-up.sh $1 $2 $3 $4 $5)"

echo "removing current nameserver from /etc/resolv.conf"
# workaround for Docker making /etc/resolv.conf "special"...
cp /etc/resolv.conf /etc/resolv.conf.orig
grep -v '^nameserver' /etc/resolv.conf.orig > /etc/resolv.conf

echo "adding $DNS1 and $DNS2 to /etc/resolv.conf"
echo -e "nameserver $DNS1\nnameserver $DNS2" >> /etc/resolv.conf

# replace current default route with via $PPP_REMOTE dev $PPP_IFACE
echo "Removing default route..."
ip route del default
echo "Adding new default route via $PPP_REMOTE dev $PPP_IFACE"
ip route add default via $PPP_REMOTE dev $PPP_IFACE

echo "Verifying with: ping -I $PPP_IFACE -c 3 api.twilio.com"
ping -I $PPP_IFACE -c 3 api.twilio.com

echo "Running tinyproxy..."
/etc/init.d/tinyproxy start
