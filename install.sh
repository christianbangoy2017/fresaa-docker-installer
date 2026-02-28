#!/bin/bash
set -e

echo "======================================"
echo "   FRESAA Docker Auto Installer"
echo "======================================"

# -------------------------------
# CONFIG
# -------------------------------
DEPLOY_DIR="/opt/fresaa"
REPO_DIR=$(pwd)

# -------------------------------
# 1. Check Docker
# -------------------------------
echo "[1/7] Checking Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker already installed."
fi

# -------------------------------
# 2. Create deployment directory
# -------------------------------
echo "[2/7] Creating deployment directory..."
sudo mkdir -p $DEPLOY_DIR
sudo chown -R $USER:$USER $DEPLOY_DIR

# -------------------------------
# 3. Copy project files
# -------------------------------
echo "[3/7] Copying project files..."
mkdir -p $DEPLOY_DIR/backend
mkdir -p $DEPLOY_DIR/frontend


echo "[3/7a Unzip frontend]"
sudo unzip frontend.zip
echo "[3/7b Unzip backend]"
sudo unzip backend.zip


cp -r $REPO_DIR/backend/* $DEPLOY_DIR/backend/
cp -r $REPO_DIR/frontend/* $DEPLOY_DIR/frontend/
cp $REPO_DIR/docker-compose.yml $DEPLOY_DIR/
cp $REPO_DIR/.env.example $DEPLOY_DIR/.env

cd $DEPLOY_DIR

# -------------------------------
# 4. Stop existing containers
# -------------------------------
echo "[4/7] Stopping existing containers (if any)..."
docker compose down || true

# -------------------------------
# 5. Update docker-compose.yml for MariaDB port 3316 and remove version line
# -------------------------------
echo "[5/7] Updating docker-compose.yml..."
if grep -q "version:" docker-compose.yml; then
    sed -i '/version:/d' docker-compose.yml
fi

# Change MariaDB host port if 3306 is present
sed -i 's/3306:3306/3316:3306/' docker-compose.yml || true

# -------------------------------
# 6. Build and start containers
# -------------------------------
echo "[6/7] Building containers..."
docker compose build --no-cache
echo "[6/7] Starting services..."
docker compose up -d

# -------------------------------
# 7. Check running containers
# -------------------------------
echo "[7/7] Listing running containers..."
docker ps

echo "======================================"
echo "   FRESAA Docker Installation Done!"
echo "   Backend: http://SERVER-IP:3001"
echo "   Frontend: http://SERVER-IP:5000"
echo "======================================"
