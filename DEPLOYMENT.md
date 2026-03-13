# Luma UI - Deployment Guide

Guide для развертывания Luma UI на VPS сервере.

## 📋 Требования

- **Node.js**: v18+ ([Download](https://nodejs.org/))
- **pnpm**: v8+ ([Install](https://pnpm.io/installation))
- **Git**: для клонирования репо
- **Docker** (опционально): для контейнеризации

---

## 🚀 Быстрое развертывание

### Вариант 1: Автоматическое развертывание (рекоменлось)

```bash
# Скачайте скрипт развертывания
git clone https://github.com/ivatra/luma-ui.git
cd luma-ui

# Запустите deploy скрипт
./deploy.sh your-domain.com 3000 /opt/luma-ui
```

**Параметры скрипта:**
- `domain` - доменное имя (по умолчанию: localhost)
- `port` - порт сервера (по умолчанию: 3000)
- `app_path` - путь установки приложения (по умолчанию: /opt/luma-ui)

---

## 🔧 Ручное развертывание

### Шаг 1: Клонирование репозитория

```bash
git clone https://github.com/ivatra/luma-ui.git /opt/luma-ui
cd /opt/luma-ui
```

### Шаг 2: Установка зависимостей

```bash
pnpm install --frozen-lockfile
```

### Шаг 3: Сборка проекта

```bash
pnpm build       # Собрать Luma пакет
pnpm docs:build  # Собрать документацию
```

### Шаг 4: Запуск сервера

**Локально (для разработки):**
```bash
pnpm docs:dev  # http://localhost:5173
```

**Production (встроенный HTTP сервер):**
```bash
pnpm serve:docs  # PORT=3000 pnpm serve:docs
```

---

## 🔌 Systemd Service (Linux)

Автоматизированный запуск сервиса в фоновом режиме.

### Создание сервиса

```bash
sudo tee /etc/systemd/system/luma-ui.service > /dev/null <<EOF
[Unit]
Description=Luma UI Service
After=network.target

[Service]
Type=simple
User=luma
WorkingDirectory=/opt/luma-ui
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/pnpm run serve:docs
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

### Управление сервисом

```bash
# Включить автозапуск
sudo systemctl enable luma-ui

# Запустить сервис
sudo systemctl start luma-ui

# Проверить статус
sudo systemctl status luma-ui

# Просмотр логов
sudo journalctl -u luma-ui -f

# Перезапустить
sudo systemctl restart luma-ui

# Остановить
sudo systemctl stop luma-ui
```

---

## 🌐 Nginx Reverse Proxy

Используйте Nginx для проксирования трафика на ваш Luma UI сервер.

### Установка Nginx

```bash
sudo apt update
sudo apt install nginx
```

### Конфигурация Nginx

```bash
sudo tee /etc/nginx/sites-available/luma-ui > /dev/null <<'EOF'
upstream luma_ui {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  listen [::]:80;
  server_name your-domain.com www.your-domain.com;

  location / {
    proxy_pass http://luma_ui;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # Кэширование статических файлов
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
  }

  # Security headers
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;
}
EOF

# Активировать конфигурацию
sudo ln -sf /etc/nginx/sites-available/luma-ui /etc/nginx/sites-enabled/luma-ui

# Проверить синтаксис
sudo nginx -t

# Перезагрузить Nginx
sudo systemctl reload nginx
```

---

## 🔒 SSL/TLS с Let's Encrypt

```bash
# Установить Certbot
sudo apt install certbot python3-certbot-nginx

# Получить сертификат
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Автоматическое обновление
sudo systemctl enable certbot.timer
```

---

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Установить pnpm
RUN npm install -g pnpm

# Копировать файлы
COPY . .

# Установить зависимости
RUN pnpm install --frozen-lockfile

# Собрать проект
RUN pnpm build && pnpm docs:build

# Expose port
EXPOSE 3000

# Start server
CMD ["pnpm", "serve:docs"]
```

### Сборка и запуск Docker образа

```bash
# Собрать образ
docker build -t luma-ui .

# Запустить контейнер
docker run -p 3000:3000 luma-ui

# С переменными окружения
docker run -e PORT=3000 -p 3000:3000 luma-ui
```

### Docker Compose

```yaml
version: '3.8'

services:
  luma-ui:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: always
    volumes:
      - /opt/luma-ui:/app
```

Запуск:
```bash
docker-compose up -d
```

---

## 📝 Скрипты для обновления

### Автоматическое обновление

```bash
# Скрипт автоматически создается при deploy
./update.sh

# Или используйте пакет-скрипт
pnpm run deploy-update
```

---

## 📊 Мониторинг

### Проверка статуса

```bash
# Статус сервиса
sudo systemctl status luma-ui

# Проверка портов
sudo netstat -tuln | grep 3000

# Логи
sudo journalctl -u luma-ui -f

# CPU и Memory usage
top
htop  # если установлен
```

---

## 🚀 Production Best Practices

1. **Используйте PM2** для управления процессами:
   ```bash
   npm install -g pm2
   pm2 start "pnpm serve:docs" --name luma-ui
   pm2 startup
   pm2 save
   ```

2. **Включите compression** в Nginx для уменьшения размер ов:
   ```nginx
   gzip on;
   gzip_types text/plain text/css text/js application/js application/json;
   gzip_min_length 1000;
   ```

3. **Установите rate limiting**:
   ```nginx
   limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
   location / {
     limit_req zone=general burst=20 nodelay;
     ...
   }
   ```

4. **Используйте CDN** для статических файлов

5. **Регулярные обновления**:
   ```bash
   cd /opt/luma-ui
   git pull origin main
   pnpm install --frozen-lockfile
   pnpm build && pnpm docs:build
   sudo systemctl restart luma-ui
   ```

---

## 🆘 Troubleshooting

### Port уже занят
```bash
# Найти процесс на порту 3000
sudo lsof -i :3000

# Убить процесс
sudo kill -9 <PID>

# Или использовать другой порт
PORT=3001 pnpm serve:docs
```

### Nginx не находит upstream
```bash
sudo systemctl reload nginx
sudo systemctl restart luma-ui
```

### Проблемы с правами доступа
```bash
# Изменить владельца папки
sudo chown -R $USER:$USER /opt/luma-ui

# Установить правильные права
sudo chmod -R 755 /opt/luma-ui
```

### Очистка кэша и переустановка
```bash
cd /opt/luma-ui
pnpm clean
rm -rf node_modules pnpm-lock.yaml
pnpm install --frozen-lockfile
pnpm build && pnpm docs:build
```

---

## 📞 Support

- **Документация**: [GitHub Wiki]
- **Issues**: [GitHub Issues](https://github.com/ivatra/luma-ui/issues)
- **Email**: ivatra@yandex.ru

---

**Версия**: 0.0.1-beta  
**Последнее обновление**: 2026-03-13
