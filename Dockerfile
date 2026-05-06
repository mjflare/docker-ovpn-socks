FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    openvpn \
    tinyproxy \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for OpenVPN config
RUN mkdir -p /opt/ovpn

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy tinyproxy configuration template
COPY tinyproxy.conf.template /etc/tinyproxy/tinyproxy.conf.template

# Expose proxy port (will be configurable)
EXPOSE 8888

RUN apk add --no-cache openvpn dante-server iproute2

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
