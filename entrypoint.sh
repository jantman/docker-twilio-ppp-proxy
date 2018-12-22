#!/bin/bash -e

echo "Setting modem device to /dev/${MODEM_DEV} in /etc/ppp/peers/twilio"
sed -i "s/ttyUSB0/${MODEM_DEV}/" /etc/ppp/peers/twilio
echo "Executing 'pon twilio'..."
pon twilio
