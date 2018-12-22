#!/bin/bash

set -o errexit
readonly LOG_FILE="/var/log/twilio-ppp"
exec 1>>$LOG_FILE
exec 2>&1

PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"
# also DNS1 and DNS2 are set

echo "ppp ip-down script called for ${PPP_IFACE} (DNS1=${DNS1} DNS2=${DNS2} ip-down.sh $1 $2 $3 $4 $5)"
echo "executing: pkill -f tinyproxy"
# This **should** result in the container exiting...
pkill -f tinyproxy
echo "executing: kill 1"
kill 1
