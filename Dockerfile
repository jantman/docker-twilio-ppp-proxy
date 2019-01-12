FROM debian:stretch
ARG git_version
ARG git_remote=https://github.com/jantman/docker-twilio-ppp-proxy
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="twilio-ppp-proxy" \
    org.label-schema.url="https://github.com/jantman/docker-twilio-ppp-proxy" \
    org.label-schema.vcs-url=$git_remote \
    org.label-schema.vcs-ref=$git_version

# make this explicit
USER root

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN apt-get update && apt-get install -y \
    curl \
    ppp \
    rsyslog \
    tinyproxy \
    unzip \
    usb-modeswitch \
    usbutils \
&& rm -rf /var/lib/apt/lists/* \
&& mkdir -p /etc/chatscripts

COPY twilio-wireless-ppp-scripts/chatscripts/twilio /etc/chatscripts/twilio
COPY twilio-wireless-ppp-scripts/peers/twilio /etc/ppp/peers/twilio
COPY entrypoint.sh /entrypoint.sh
COPY ip-up.sh /etc/ppp/ip-up.d/9999proxy
COPY ip-down.sh /etc/ppp/ip-down.d/9999proxy
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY rsyslog.conf /etc/rsyslog.conf

RUN chmod +x \
    /tini \
    /entrypoint.sh \
    /etc/ppp/ip-up.d/9999proxy \
    /etc/ppp/ip-down.d/9999proxy

EXPOSE 8888
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]

HEALTHCHECK --interval=15m --timeout=1m --start-period=5m \
  CMD /usr/bin/curl -f --proxy http://127.0.0.1:8888 http://api.ipify.org/ || exit 1
