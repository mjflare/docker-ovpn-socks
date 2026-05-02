#!/bin/bash

###############################################################################
# OpenVPN Proxy Server - Full Automated Installer
# Deploy with: curl -fsSL https://raw.githubusercontent.com/mjflare/docker-ovpn-socks/main/install.sh | bash
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║         OpenVPN Proxy Server - Auto Installer               ║
║                                                              ║
║  One-command deployment via: curl -fsSL ... | bash          ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

###############################################################################
# Check Prerequisites
###############################################################################

echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo "Install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    echo "Install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is installed${NC}"

###############################################################################
# Interactive Configuration
###############################################################################

echo -e "\n${YELLOW}[2/6] Configuration Setup${NC}"

# Default values
DEFAULT_OVPN_DIR="/opt/ovpn"
DEFAULT_PROXY_PORT="8888"
DEFAULT_OVPN_CONFIG="client.ovpn"
DEFAULT_LOG_LEVEL="info"

# Ask for configurations
read -p "📁 OpenVPN config directory [${DEFAULT_OVPN_DIR}]: " OVPN_DIR
OVPN_DIR=${OVPN_DIR:-$DEFAULT_OVPN_DIR}

read -p "🔌 Proxy server port [${DEFAULT_PROXY_PORT}]: " PROXY_PORT
PROXY_PORT=${PROXY_PORT:-$DEFAULT_PROXY_PORT}

read -p "📄 OpenVPN config filename [${DEFAULT_OVPN_CONFIG}]: " OVPN_CONFIG
OVPN_CONFIG=${OVPN_CONFIG:-$DEFAULT_OVPN_CONFIG}

read -p "📊 Log level [${DEFAULT_LOG_LEVEL}] (info/notice/warn/error): " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}

# Validate port number
if ! [[ "$PROXY_PORT" =~ ^[0-9]+$ ]] || [ "$PROXY_PORT" -lt 1024 ] || [ "$PROXY_PORT" -gt 65535 ]; then
    echo -e "${RED}❌ Invalid port number!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration set${NC}"

###############################################################################
# Clone/Setup Repository
###############################################################################

echo -e "\n${YELLOW}[3/6] Setting up project directory...${NC}"

PROJECT_DIR="$HOME/openvpn-proxy"
REPO_URL="https://github.com/mjflare/docker-ovpn-socks.git"

# Clone or update repository
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "📦 Updating existing project..."
    cd "$PROJECT_DIR"
    git pull origin main
else
    echo "📦 Cloning repository..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

echo -e "${GREEN}✓ Project directory ready: $PROJECT_DIR${NC}"

###############################################################################
# Create .env file
###############################################################################

echo -e "\n${YELLOW}[4/6] Creating configuration file...${NC}"

cat > "$PROJECT_DIR/.env" << EOF
# OpenVPN Proxy Server Configuration
# Generated on $(date)

# Directory containing your .ovpn file
OVPN_DIR=$OVPN_DIR

# Port for the proxy server
PROXY_PORT=$PROXY_PORT

# Name of your OpenVPN config file
OVPN_CONFIG=$OVPN_CONFIG

# Log level: info, notice, warn, error
LOG_LEVEL=$LOG_LEVEL

# Container name (optional)
COMPOSE_PROJECT_NAME=openvpn-proxy
EOF

echo -e "${GREEN}✓ Configuration file created: $PROJECT_DIR/.env${NC}"

###############################################################################
# Create OpenVPN directory
###############################################################################

echo -e "\n${YELLOW}[5/6] Setting up OpenVPN directory...${NC}"

if [ ! -d "$OVPN_DIR" ]; then
    echo "📁 Creating directory: $OVPN_DIR"
    sudo mkdir -p "$OVPN_DIR"
    sudo chmod 755 "$OVPN_DIR"
fi

OVPN_FILE="$OVPN_DIR/$OVPN_CONFIG"

if [ ! -f "$OVPN_FILE" ]; then
    echo -e "${YELLOW}⚠️  OpenVPN config file not found!${NC}"
    echo "Please provide the path to your .ovpn file:"
    read -p "Enter path to .ovpn file: " OVPN_SOURCE
    
    if [ -f "$OVPN_SOURCE" ]; then
        echo "📋 Copying configuration file..."
        sudo cp "$OVPN_SOURCE" "$OVPN_FILE"
        sudo chmod 600 "$OVPN_FILE"
        echo -e "${GREEN}✓ OpenVPN config copied: $OVPN_FILE${NC}"
    else
        echo -e "${YELLOW}⚠️  .ovpn file not found at: $OVPN_SOURCE${NC}"
        echo "You can add it later to: $OVPN_DIR/"
    fi
else
    echo -e "${GREEN}✓ OpenVPN config found: $OVPN_FILE${NC}"
fi

###############################################################################
# Deploy with Docker Compose
###############################################################################

echo -e "\n${YELLOW}[6/6] Deploying container...${NC}"

cd "$PROJECT_DIR"

echo "🚀 Starting Docker Compose..."
docker-compose up -d

# Wait for container to start
echo "⏳ Waiting for container to be ready..."
sleep 5

# Check container status
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Container is running!${NC}"
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo "View logs with: docker-compose logs"
    exit 1
fi

###############################################################################
# Display Success Message
###############################################################################

echo -e "\n${GREEN}"
cat << EOF
╔══════════════════════════════════════════════════════════════╗
║             ✅ Deployment Successful!                        ║
╚══════════════════════════════════════════════════════════════╝

📍 Project Location: $PROJECT_DIR

📋 Configuration:
   - OpenVPN Dir:    $OVPN_DIR
   - Config File:    $OVPN_CONFIG
   - Proxy Port:     $PROXY_PORT
   - Log Level:      $LOG_LEVEL

🧪 Test the Proxy:
   curl -x http://localhost:$PROXY_PORT https://ifconfig.me

📊 View Logs:
   cd $PROJECT_DIR
   docker-compose logs -f

🛑 Stop Container:
   cd $PROJECT_DIR
   docker-compose down

♻️  Restart Container:
   cd $PROJECT_DIR
   docker-compose restart

📖 Full Documentation:
   https://github.com/mjflare/docker-ovpn-socks

═══════════════════════════════════════════════════════════════

💡 Proxy Usage Examples:

   Python:
   import requests
   proxies = {'http': 'http://localhost:$PROXY_PORT', 'https': 'http://localhost:$PROXY_PORT'}
   requests.get('https://ifconfig.me', proxies=proxies)

   Node.js:
   const agent = new HttpProxyAgent('http://localhost:$PROXY_PORT');

   WGET:
   wget -e use_proxy=yes -e http_proxy=http://localhost:$PROXY_PORT -O - https://ifconfig.me

═══════════════════════════════════════════════════════════════

⚠️  Important:
   - Make sure your .ovpn file is at: $OVPN_FILE
   - Container will auto-restart on failure
   - Check logs if proxy is not responding

═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

echo -e "${BLUE}✨ Installation complete! Your OpenVPN proxy is ready to use.${NC}\n"
