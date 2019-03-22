#!/bin/bash

set -o errexit
[ -z ${DEBUG+x} ] && set -o xtrace

PPP_IFACE="$1"
PPP_TTY="$2"
PPP_SPEED="$3"
PPP_LOCAL="$4"
PPP_REMOTE="$5"

logger -t ip-up-script "ppp ip-up script called for ${PPP_IFACE} (DNS1=${DNS1} DNS2=${DNS2} ip-up.sh $1 $2 $3 $4 $5)"

# workaround for Docker making /etc/resolv.conf "special"...
cp /etc/resolv.conf /etc/resolv.conf.orig

# remove nameserver only if present
if grep '^nameserver' /etc/resolv.conf.orig; then
  if grep -v '^nameserver' /etc/resolv.conf.orig; then
    logger -t ip-up-script "removing current nameserver from /etc/resolv.conf"
    grep -v '^nameserver' /etc/resolv.conf.orig > /etc/resolv.conf
  else
    logger -t ip-up-script "truncating /etc/resolv.conf"
    truncate -s 0 /etc/resolv.conf
  fi
fi

logger -t ip-up-script "adding $DNS1 and $DNS2 to /etc/resolv.conf"
echo -e "nameserver $DNS1\nnameserver $DNS2" >> /etc/resolv.conf

# replace current default route with via $PPP_REMOTE dev $PPP_IFACE
logger -t ip-up-script "Removing default route..."
ip route del default
logger -t ip-up-script "Adding new default route via $PPP_REMOTE dev $PPP_IFACE"
ip route add default via $PPP_REMOTE dev $PPP_IFACE

logger -t ip-up-script "Verifying with: ping -I $PPP_IFACE -c 5 www.twilio.com"
if ping -I $PPP_IFACE -c 5 www.twilio.com &>/tmp/ping.out; then
  logger -t ip-up-script -f /tmp/ping.out
  logger -t ip-up-script "ping succeeded; connectivity confirmed"
else
  logger -t ip-up-script -f /tmp/ping.out
  logger -t ip-up-script "ping failed all attempts; killing container (PID 1)"
  # sleep 5 seconds to ensure logging flushes
  sleep 5
  kill 1
fi

if [ ! -z ${PREPROXY_EXEC+x} ]; then
  echo "Executing PREPROXY_EXEC: ${PREPROXY_EXEC}"
  bash -c "$PREPROXY_EXEC"
fi

logger -t ip-up-script "Running tinyproxy..."
/etc/init.d/tinyproxy start
