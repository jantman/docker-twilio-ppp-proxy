#!/bin/bash

sleep 3
logger -t exit_when_ppp_dead.sh "waiting for pppd to exit..."
while pgrep -f /usr/sbin/pppd > /dev/null; do sleep 1; done
logger -t exit_when_ppp_dead.sh "/usr/sbin/pppd is no longer running!"
logger -t exit_when_ppp_dead.sh "executing: pkill -f tinyproxy"
# This **should** result in the container exiting...
pkill -f tinyproxy
logger -t exit_when_ppp_dead.sh "executing: kill 1"
kill 1
