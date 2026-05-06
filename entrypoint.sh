#!/bin/sh
set -e

echo "[*] Starting OpenVPN..."
openvpn --config /vpn/client.ovpn --daemon

echo "[*] Waiting for tun0..."

# Wait until VPN is ready
for i in $(seq 1 30); do
    if ip link show tun0 > /dev/null 2>&1; then
        echo "[+] tun0 is up"
        break
    fi
    sleep 1
done

# Fail if tun0 not up
if ! ip link show tun0 > /dev/null 2>&1; then
    echo "[!] tun0 not found, exiting"
    exit 1
fi

echo "[*] Forcing traffic through VPN..."

# Remove default route and force VPN
ip route del default || true
ip route add default dev tun0

# (Optional but recommended) Kill-switch
iptables -F
iptables -t nat -F
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A OUTPUT -j DROP

echo "[*] Starting SOCKS5 server..."
exec sockd -f /etc/sockd.conf
