#!/bin/bash -e

echo "Setting modem device to /dev/${MODEM_DEV} in /etc/ppp/peers/twilio" >> /var/log/twilio-ppp
sed -i "s/ttyUSB0/${MODEM_DEV}/" /etc/ppp/peers/twilio
echo "Executing 'pon twilio'..." >> /var/log/twilio-ppp
pon twilio
