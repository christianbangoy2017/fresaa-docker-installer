#!/bin/bash
set -e

echo "======================================"
echo "   FRESAA Docker Auto Installer"
echo "======================================"

BASE_DIR="/opt/fresaa"
REPO_DIR=$(pwd)

echo "[1/7] Checking Docker..."

if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing..."
    sudo apt update
    sudo apt install docker.io docker-compose -y
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
else
    echo "Docker already installed."
fi

echo "[2/7] Creating deployment directory..."
sudo mkdir -p $BASE_DIR
sudo chown -R $USER:$USER $BASE_DIR

echo "[3/7] Copying project files..."
cp -r $REPO_DIR/* $BASE_DIR/

cd $BASE_DIR

echo "[4/7] Stopping existing containers (if any)..."
docker compose down || true

echo "[5/7] Building containers..."
docker compose build --no-cache

echo "[6/7] Starting services..."
docker compose up -d

echo "[7/7] Checking running containers..."
docker ps

echo "======================================"
echo " FRESAA Installation Complete"
echo "======================================"
echo ""
echo "Access Frontend:"
echo "http://SERVER-IP"
echo ""
echo "Access Backend:"
echo "http://SERVER-IP:3001"
echo ""
