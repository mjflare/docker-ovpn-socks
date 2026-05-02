#!/bin/bash

# Load environment variables from .env file
if [ -f /app/.env ]; then
    export $(cat /app/.env | grep -v '^#' | xargs)
fi

# Set defaults if not provided
OVPN_DIR=${OVPN_DIR:-/opt/ovpn}
PROXY_PORT=${PROXY_PORT:-8888}
OVPN_CONFIG=${OVPN_CONFIG:-client.ovpn}
LOG_LEVEL=${LOG_LEVEL:-info}

echo "[$(date)] Starting OpenVPN Proxy Server..."
echo "[$(date)] Configuration:"
echo "  - OVPN_DIR: $OVPN_DIR"
echo "  - OVPN_CONFIG: $OVPN_CONFIG"
echo "  - PROXY_PORT: $PROXY_PORT"
echo "  - LOG_LEVEL: $LOG_LEVEL"

# Check if .ovpn file exists
OVPN_FILE="$OVPN_DIR/$OVPN_CONFIG"
if [ ! -f "$OVPN_FILE" ]; then
    echo "[ERROR] OpenVPN configuration file not found: $OVPN_FILE"
    echo "[ERROR] Please mount your .ovpn file to $OVPN_DIR/"
    exit 1
fi

echo "[$(date)] Found OpenVPN config: $OVPN_FILE"

# Generate tinyproxy configuration
echo "[$(date)] Generating tinyproxy configuration..."
if [ -f /etc/tinyproxy/tinyproxy.conf.template ]; then
    sed "s|{{PROXY_PORT}}|$PROXY_PORT|g" /etc/tinyproxy/tinyproxy.conf.template > /etc/tinyproxy/tinyproxy.conf
    sed -i "s|{{LOG_LEVEL}}|$LOG_LEVEL|g" /etc/tinyproxy/tinyproxy.conf
else
    echo "[WARNING] tinyproxy.conf.template not found, using default config"
fi

# Start OpenVPN in background
echo "[$(date)] Starting OpenVPN..."
openvpn --config "$OVPN_FILE" \
    --log /var/log/openvpn.log \
    --verb 3 \
    --daemon \
    --auth-nocache

# Wait for VPN connection to establish
echo "[$(date)] Waiting for VPN connection to establish..."
sleep 5

# Check if VPN is connected
if ip link show tun0 > /dev/null 2>&1; then
    echo "[$(date)] ✓ VPN connected successfully (tun0 interface active)"
else
    echo "[$(date)] ⚠ VPN interface not found, but continuing..."
fi

# Start tinyproxy
echo "[$(date)] Starting tinyproxy on port $PROXY_PORT..."
tinyproxy -c /etc/tinyproxy/tinyproxy.conf

# Keep container running
tail -f /var/log/openvpn.log
