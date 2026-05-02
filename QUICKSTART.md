# Quick Start Guide

## 30-Second Setup

```bash
# 1. Run installer
curl -fsSL https://raw.githubusercontent.com/mjflare/docker-ovpn-socks/main/install.sh | bash

# 2. Follow prompts
# - Enter OpenVPN directory (or press Enter for /opt/ovpn)
# - Enter proxy port (or press Enter for 8888)
# - Provide path to your .ovpn file

# 3. Done! Proxy is live
```

## 📝 What You Need

1. **Docker** - Install from https://docs.docker.com/get-docker/
2. **Docker Compose** - Included with Docker Desktop
3. **OpenVPN Config** - Your `.ovpn` file from your VPN provider

## 🧪 Instant Test

```bash
# After installation, test immediately:
curl -x http://localhost:8888 https://ifconfig.me

# You should see your VPN provider's IP
```

## 🔧 Change Configuration

```bash
cd ~/openvpn-proxy
vim .env          # Edit configuration
docker-compose restart  # Apply changes
```

## 📚 More Info

- See `README.md` for full documentation
- See `DEPLOYMENT.md` for detailed guide
- See `install.sh` for what installer does

---

**That's it! Your OpenVPN proxy is now running.** 🚀
