FROM alpine:3.19

RUN apk add --no-cache \
    openvpn \
    dante-server \
    iproute2 \
    iptables \
    bash

COPY sockd.conf /etc/sockd.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
