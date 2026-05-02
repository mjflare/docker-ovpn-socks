# OpenVPN Proxy Server 🔒

A lightweight Docker container that runs **OpenVPN as a client** and exposes a **proxy server** on `localhost:port` to route all traffic through the VPN tunnel.

## Features

✅ **OpenVPN Client** - Connects to your VPN server  
✅ **Proxy Server** - Tinyproxy running on configurable port  
✅ **Easy Configuration** - Simple `.env` file setup  
✅ **Custom .ovpn Directory** - Default `/opt/ovpn` with override support  
✅ **Flexible Port Selection** - Configure proxy port via environment  
✅ **Docker Compose Ready** - One-command deployment  
✅ **Health Checks** - Auto-restart on failure  
✅ **Secure** - `.ovpn` files protected from git  

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/mjflare/docker-ovpn-socks.git
cd docker-ovpn-socks
```

### 2. Setup Configuration
```bash
# Copy example env file
cp .env.example .env

# Copy your .ovpn file to default location
mkdir -p /opt/ovpn
cp your-config.ovpn /opt/ovpn/client.ovpn
```

### 3. Deploy
```bash
docker-compose up -d
```

### 4. Test Proxy
```bash
# Test connectivity
curl -x http://localhost:8888 https://ifconfig.me

# Or with wget
wget -e use_proxy=yes -e http_proxy=http://localhost:8888 -O - https://ifconfig.me
```

## Configuration

### .env Variables

Create a `.env` file in the project root:

```bash
# Directory containing your .ovpn file (default: /opt/ovpn)
OVPN_DIR=/opt/ovpn

# Port for the proxy server (default: 8888)
PROXY_PORT=8888

# Name of your OpenVPN config file (default: client.ovpn)
OVPN_CONFIG=client.ovpn

# Log level: info, notice, warn, error (default: info)
LOG_LEVEL=info
```

### Custom Configuration Example

```bash
# Use a different port
PROXY_PORT=3128

# Use a different config directory
OVPN_DIR=/home/user/vpn-configs

# Use a different config file name
OVPN_CONFIG=my-vpn.ovpn

# Verbose logging
LOG_LEVEL=notice
```

## Usage Examples

### Python
```python
import requests

proxies = {
    'http': 'http://localhost:8888',
    'https': 'http://localhost:8888',
}

response = requests.get('https://ifconfig.me', proxies=proxies)
print(response.text)
```

### Node.js
```javascript
const https = require('https');
const HttpProxyAgent = require('http-proxy-agent');

const agent = new HttpProxyAgent('http://localhost:8888');
const options = {
    hostname: 'ifconfig.me',
    agent: agent
};

https.get(options, (res) => {
    res.pipe(process.stdout);
});
```

### cURL
```bash
# Simple request through proxy
curl -x http://localhost:8888 https://ifconfig.me

# With authentication (if needed)
curl -x http://user:pass@localhost:8888 https://ifconfig.me
```

### WGET
```bash
wget -e use_proxy=yes -e http_proxy=http://localhost:8888 -O - https://ifconfig.me
```

## Docker Commands

### View Logs
```bash
docker-compose logs -f openvpn-proxy
```

### Stop Container
```bash
docker-compose down
```

### Rebuild Image
```bash
docker-compose up --build -d
```

### Check Status
```bash
docker-compose ps
```

### Access Container Shell
```bash
docker-compose exec openvpn-proxy bash
```

## Troubleshooting

### VPN Connection Failed
1. Verify `.ovpn` file exists at the specified path
2. Check logs: `docker-compose logs openvpn-proxy`
3. Ensure `.ovpn` has correct permissions: `chmod 600 /opt/ovpn/client.ovpn`

### Proxy Connection Refused
1. Check if proxy port is already in use: `netstat -tlnp | grep 8888`
2. Verify container is running: `docker-compose ps`
3. Ensure firewall allows the port

### VPN Connected but No Traffic
1. Check tun0 interface: `docker-compose exec openvpn-proxy ip link show tun0`
2. Verify proxy is listening: `docker-compose exec openvpn-proxy netstat -tlnp | grep tinyproxy`

### Container Keeps Restarting
1. Check health status: `docker-compose ps`
2. Review logs for errors: `docker-compose logs --tail 50 openvpn-proxy`
3. Ensure volumes are mounted correctly

## Security Considerations

⚠️ **Important Security Notes:**

1. `.ovpn` files are **git-ignored** for security
2. Only expose this proxy on trusted networks
3. Consider adding authentication in tinyproxy config for production use
4. Regularly update OpenVPN certificates
5. Use strong passwords in your `.ovpn` configuration
6. Don't commit `.env` files with sensitive data

## Advanced Configuration

### Custom Tinyproxy Settings
Edit `tinyproxy.conf.template` to customize:
- Connection limits
- Access control lists
- Logging levels
- Upstream proxies

### Multiple Instances
Run multiple proxy servers on different ports:
```bash
# Terminal 1
PROXY_PORT=8888 docker-compose up -d

# Terminal 2
PROXY_PORT=8889 docker-compose -f docker-compose.yml -p proxy2 up -d
```

## License

MIT License - Feel free to use and modify

## Support

For issues, questions, or contributions:
- Check existing issues on GitHub
- Review the troubleshooting section
- Check OpenVPN and Tinyproxy documentation

---

**Happy VPN Proxying! 🚀**
