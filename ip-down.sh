#!/bin/bash -e
PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"
# also DNS1 and DNS2 are set

echo "ppp ip-down script called for ${PPP_IFACE} (DNS1=${DNS1} DNS2=${DNS2} ip-down.sh $1 $2 $3 $4 $5)" >> /var/log/twilio-ppp
echo "executing: pkill -f tinyproxy" >> /var/log/twilio-ppp
# This **should** result in the container exiting...
pkill -f tinyproxy
