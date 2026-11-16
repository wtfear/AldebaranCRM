#!/bin/sh
set -e

# Copy .env if not exists
if [ ! -f "/var/www/html/.env" ]; then
    cp /var/www/html/.env.example /var/www/html/.env
fi

# Generate application key if missing
if ! grep -q "^APP_KEY=base64" /var/www/html/.env; then
    php artisan key:generate --force || true
fi

# Clear and optimize config
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

exec "$@"
