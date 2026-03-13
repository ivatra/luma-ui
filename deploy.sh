#!/bin/bash

# Luma UI Deployment Script
# Usage: ./deploy.sh [domain] [port] [app-path]
# Example: ./deploy.sh luma-ui.com 3000 /opt/luma-ui

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOMAIN=${1:-"localhost"}
PORT=${2:-3000}
APP_PATH=${3:-"/opt/luma-ui"}
NODE_ENV="production"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Luma UI Deployment Script${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}Domain: $DOMAIN${NC}"
echo -e "${YELLOW}Port: $PORT${NC}"
echo -e "${YELLOW}App Path: $APP_PATH${NC}"
echo ""

# Step 1: Check requirements
echo -e "${BLUE}Step 1: Checking requirements...${NC}"
command -v node >/dev/null 2>&1 || { echo -e "${RED}Node.js is required but not installed.${NC}"; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo -e "${YELLOW}Installing pnpm...${NC}"; npm install -g pnpm; }

echo -e "${GREEN}✓ Node.js $(node -v)${NC}"
echo -e "${GREEN}✓ pnpm $(pnpm -v)${NC}"
echo ""

# Step 2: Clone or update repository
echo -e "${BLUE}Step 2: Setting up project directory...${NC}"
if [ -d "$APP_PATH" ]; then
  echo -e "${YELLOW}Directory exists. Pulling latest changes...${NC}"
  cd "$APP_PATH"
  git pull origin main
else
  echo -e "${YELLOW}Cloning repository...${NC}"
  mkdir -p "$(dirname $APP_PATH)"
  git clone https://github.com/ivatra/luma-ui.git "$APP_PATH"
  cd "$APP_PATH"
fi

echo -e "${GREEN}✓ Project ready at $APP_PATH${NC}"
echo ""

# Step 3: Install dependencies
echo -e "${BLUE}Step 3: Installing dependencies...${NC}"
pnpm install --frozen-lockfile
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 4: Build project
echo -e "${BLUE}Step 4: Building project...${NC}"
pnpm build
pnpm docs:build
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Step 5: Create systemd service
echo -e "${BLUE}Step 5: Creating systemd service...${NC}"
SYSTEMD_SERVICE="/etc/systemd/system/luma-ui.service"

if [ ! -f "$SYSTEMD_SERVICE" ]; then
  sudo tee "$SYSTEMD_SERVICE" > /dev/null <<EOF
[Unit]
Description=Luma UI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_PATH
Environment="NODE_ENV=$NODE_ENV"
Environment="PORT=$PORT"
ExecStart=/usr/bin/pnpm run serve:docs
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
  echo -e "${GREEN}✓ Systemd service created${NC}"
else
  echo -e "${YELLOW}Systemd service already exists${NC}"
fi
echo ""

# Step 6: Create nginx config (optional)
echo -e "${BLUE}Step 6: Nginx configuration${NC}"
NGINX_CONFIG="/etc/nginx/sites-available/luma-ui"

if command -v nginx >/dev/null 2>&1; then
  if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${YELLOW}Creating nginx config...${NC}"
    sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
upstream luma_ui {
  server 127.0.0.1:$PORT;
}

server {
  listen 80;
  listen [::]:80;
  server_name $DOMAIN www.$DOMAIN;

  location / {
    proxy_pass http://luma_ui;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  # Cache static files
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
  }

  # Security headers
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
EOF
    
    # Enable site
    sudo ln -sf "$NGINX_CONFIG" "/etc/nginx/sites-enabled/luma-ui"
    sudo nginx -t && sudo systemctl reload nginx
    echo -e "${GREEN}✓ Nginx configuration created and enabled${NC}"
  else
    echo -e "${YELLOW}Nginx config already exists${NC}"
  fi
else
  echo -e "${YELLOW}Nginx not installed (optional)${NC}"
fi
echo ""

# Step 7: Setup SSL (optional)
echo -e "${BLUE}Step 7: SSL Certificate (optional)${NC}"
if command -v certbot >/dev/null 2>&1; then
  echo -e "${YELLOW}Run this to setup SSL:${NC}"
  echo -e "${YELLOW}sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN${NC}"
else
  echo -e "${YELLOW}To setup SSL, install certbot first:${NC}"
  echo -e "${YELLOW}sudo apt-get install certbot python3-certbot-nginx${NC}"
fi
echo ""

# Step 8: Create deployment scripts
echo -e "${BLUE}Step 8: Creating update script...${NC}"
UPDATE_SCRIPT="$APP_PATH/update.sh"
tee "$UPDATE_SCRIPT" > /dev/null <<'EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "Updating Luma UI..."
git pull origin main
pnpm install --frozen-lockfile
pnpm build
pnpm docs:build
echo "Update complete!"
sudo systemctl restart luma-ui
EOF
chmod +x "$UPDATE_SCRIPT"
echo -e "${GREEN}✓ Update script created at $UPDATE_SCRIPT${NC}"
echo ""

# Final Summary
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Start the service:"
echo -e "   ${YELLOW}sudo systemctl start luma-ui${NC}"
echo ""
echo -e "2. Enable auto-start:"
echo -e "   ${YELLOW}sudo systemctl enable luma-ui${NC}"
echo ""
echo -e "3. Check service status:"
echo -e "   ${YELLOW}sudo systemctl status luma-ui${NC}"
echo ""
echo -e "4. View logs:"
echo -e "   ${YELLOW}sudo journalctl -u luma-ui -f${NC}"
echo ""
echo -e "5. Update the app:"
echo -e "   ${YELLOW}$UPDATE_SCRIPT${NC}"
echo ""
echo -e "${BLUE}Service will be available at:${NC}"
echo -e "${GREEN}http://$DOMAIN (if using nginx proxy)${NC}"
echo -e "${GREEN}http://localhost:$PORT (direct access)${NC}"
