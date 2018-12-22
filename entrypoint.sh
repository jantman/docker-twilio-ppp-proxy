#!/bin/bash

set -o errexit
readonly LOG_FILE="/var/log/twilio-ppp"
exec 1>>$LOG_FILE
exec 2>&1

echo "Setting modem device to /dev/${MODEM_DEV} in /etc/ppp/peers/twilio"
sed -i "s/ttyUSB0/${MODEM_DEV}/" /etc/ppp/peers/twilio
echo "Executing 'pon twilio'..."
pon twilio
