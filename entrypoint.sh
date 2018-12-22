#!/bin/bash

set -o errexit

echo "Setting modem device to /dev/${MODEM_DEV} in /etc/ppp/peers/twilio"
sed -i "s/ttyUSB0/${MODEM_DEV}/" /etc/ppp/peers/twilio

echo "Starting rsyslog..."
/etc/init.d/rsyslog start

echo "Executing 'pon twilio'..."
pon twilio

echo "Executing: tail -f /var/log/messages"
tail -f /var/log/messages
