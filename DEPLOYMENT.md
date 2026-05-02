# OpenVPN Proxy Server - Deployment Guide

## 🚀 Quick Deploy (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/mjflare/docker-ovpn-socks/main/install.sh | bash
```

That's it! The installer handles everything:
- ✅ Checks Docker/Docker Compose
- ✅ Interactive configuration
- ✅ Repository setup
- ✅ Container deployment
- ✅ Proxy testing

---

## 📋 Prerequisites

- Docker installed
- Docker Compose installed
- Your `.ovpn` file ready
- Port available (default: 8888)

---

## ⚙️ Configuration

The installer will prompt you for:

1. **OpenVPN Directory** (default: `/opt/ovpn`)
   - Where your `.ovpn` file is stored
   - Create with: `mkdir -p /opt/ovpn`

2. **Proxy Port** (default: `8888`)
   - Port where proxy will listen
   - Must be 1024-65535

3. **Config Filename** (default: `client.ovpn`)
   - Name of your OpenVPN config file

4. **Log Level** (default: `info`)
   - Options: info, notice, warn, error

---

## 📦 Installation Location

After installation:
- **Project**: `~/openvpn-proxy`
- **Config**: `~/openvpn-proxy/.env`
- **Logs**: Via `docker-compose logs`

---

## 🧪 Test Deployment

```bash
# Test proxy connection
curl -x http://localhost:8888 https://ifconfig.me

# You should see your VPN IP address
```

---

## 🛠️ Management

```bash
cd ~/openvpn-proxy

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Stop container
docker-compose down

# Restart
docker-compose restart

# Update
git pull && docker-compose up --build -d
```

---

## ⚠️ Troubleshooting

### Connection Refused
- Check if port is in use: `netstat -tlnp | grep 8888`
- Verify container running: `docker-compose ps`

### VPN Not Connecting
- Check logs: `docker-compose logs | grep -i error`
- Verify `.ovpn` file exists: `ls -la /opt/ovpn/`
- Ensure correct permissions: `chmod 600 /opt/ovpn/client.ovpn`

### Docker Not Found
- Install Docker: https://docs.docker.com/get-docker/
- Install Docker Compose: https://docs.docker.com/compose/install/

---

## 📚 Usage Examples

### Python
```python
import requests
proxies = {'http': 'http://localhost:8888', 'https': 'http://localhost:8888'}
response = requests.get('https://ifconfig.me', proxies=proxies)
print(response.text)
```

### cURL
```bash
curl -x http://localhost:8888 https://ifconfig.me
```

### WGET
```bash
wget -e use_proxy=yes -e http_proxy=http://localhost:8888 -O - https://ifconfig.me
```

### Node.js
```javascript
const https = require('https');
const HttpProxyAgent = require('http-proxy-agent');
const agent = new HttpProxyAgent('http://localhost:8888');
const options = {hostname: 'ifconfig.me', agent: agent};
https.get(options, (res) => res.pipe(process.stdout));
```

---

## 🔒 Security Notes

- `.ovpn` files are git-ignored
- `.env` file is git-ignored
- Only expose proxy on trusted networks
- Don't commit sensitive data
- Use strong passwords in `.ovpn` config

---

## 📞 Support

- Repository: https://github.com/mjflare/docker-ovpn-socks
- Issues: Check GitHub Issues
- Docs: See README.md

---

**Happy VPN Proxying! 🚀**
