#!/bin/bash

set -o errexit
[ -z ${DEBUG+x} ] && set -o xtrace

echo "Setting modem device to /dev/${MODEM_DEV} in /etc/ppp/peers/twilio"
sed -i "s/ttyUSB0/${MODEM_DEV}/" /etc/ppp/peers/twilio

echo "Starting rsyslog..."
/etc/init.d/rsyslog start

if [ -z ${DEBUG+x} ]; then
  echo "Executing 'pon twilio debug dump'..."
  pon twilio debug dump
else
  echo "Executing 'pon twilio'..."
  pon twilio
fi

echo "Executing: tail -f /var/log/messages"
tail -f /var/log/messages
