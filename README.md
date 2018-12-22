# docker-twilio-ppp-proxy

Docker container to proxy HTTP via USB PPP modem using Twilio Programmable Wireless.

## Why?

Well... suppose you have a dedicated machine running home automation/alarm system and video surveillance. You want some out-of-band (i.e. cellular) notification if you lose your normal route to the WAN or if the alarm is triggered while normal connectivity is down. **But** you're using Twilio Programmable Wireless on a small, cheap plan (~10 MB/month) and don't want HD video streaming to offsite storage or other data-intensive things trying to go over the cellular link.

So, we use an application-level solution:

1. Run a HTTP proxy in a Docker container, which routes over the cellular link.
2. At the application level, send data through the proxy only if normal connectivity fails.

Essentially, a whole lot of ugly complexity and engineering to get $3/month out-of-band notifications.

## Setup

Upon first plugging in your modem, run ``lsusb | grep Huawei``. If you see ``ID 12d1:1505 Huawei Technologies Co., Ltd. E398 LTE/UMTS/GSM Modem/Networkcard``, the USB modem is in mass storage mode. Run ``usb_modeswitch -v 12d1 -p 1505 -J`` to fix that; ``lsusb | grep Huawei`` should now report ``12d1:1506 Huawei Technologies Co., Ltd. Modem/Networkcard``.

## Usage

```
docker run -d \
    --name twilio-proxy \
    -e MODEM_DEV=ttyUSB0 \
    --privileged \
    -p 8888:8888 \
    --restart always \
    jantman/twilio-ppp-proxy
```

Test that it's working:

1. Point a browser to https://www.ipify.org/ and find your current WAN IP.
2. ``curl http://httpbin.org/ip`` should show your real/current WAN IP
3. ``curl https://api.ipify.org/?format=json`` should show the same real/current WAN IP
4. ``http_proxy=http://127.0.0.1:8888/ https_proxy=http://127.0.0.1:8888/ curl -L https://api.ipify.org/?format=json`` should show a different IP, the cellular gateway (not necessarily your PPP client IP)
5. ``http_proxy=http://127.0.0.1:8888/ https_proxy=http://127.0.0.1:8888/ curl http://httpbin.org/ip`` should show a different IP, the cellular gateway (not necessarily your PPP client IP)

## ToDo

* Try to make this a bit smaller and more efficient. Right now, this image is just using a giant hammer to get things working as quickly as possible.
* Do something better for logging than running rsyslog?
* Figure out if we can specify certain needed capabilities instead of ``--privileged``.
* Ensure that the container exits if the connection breaks/fails.
* Automatically find the modem if ``MODEM_DEV`` isn't specified?
