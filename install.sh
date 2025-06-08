#!/bin/bash

set -e

echo "[1/9] Обновляем пакеты и устанавливаем базовые утилиты..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y \
    ca-certificates curl gnupg lsb-release ufw \
    wget unzip nano git jq screen net-tools htop \
    sudo bash curl snapd \
    software-properties-common apt-transport-https

echo "[2/9] Удаляем старые версии Docker и Compose (если есть)..."
sudo systemctl stop docker || true
sudo apt-get remove -y docker docker-engine docker.io containerd runc docker-compose-plugin docker-compose || true
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose || true
sudo rm -rf /var/lib/docker /var/lib/containerd || true

echo "[3/9] Добавляем ключ Docker и репозиторий..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[4/9] Устанавливаем Docker и Compose..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "[5/9] Проверка Docker..."
docker --version
docker compose version

echo "[6/9] Настраиваем UFW (фаервол)..."
sudo ufw allow OpenSSH
sudo ufw --force enable
sudo ufw status verbose

echo "[7/9] Добавляем пользователя '$USER' в группу docker..."
sudo usermod -aG docker $USER

echo "[8/9] Проверка сетевых утилит..."
screen --version
curl --version
jq --version

echo "[9/9] Готово! Не забудь выйти и заново зайти в терминал или выполнить 'newgrp docker'"

echo ""
echo "✅ Сервер готов для запуска нод. Минимализм, безопасность и функциональность."
