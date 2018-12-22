#!/bin/bash -e
PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"
# also DNS1 and DNS2 are set

echo "ppp ip-down script called for ${PPP_IFACE} (local=${PPP_LOCAL} remote=${PPP_REMOTE} DNS=${DNS1} ${DNS2})"
echo "executing: pkill -f tinyproxy"
# This **should** result in the container exiting...
pkill -f tinyproxy
