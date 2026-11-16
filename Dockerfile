FROM php:8.3-cli-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies & PHP extensions
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    icu-dev \
    libzip-dev \
    oniguruma-dev \
    nodejs \
    npm \
    linux-headers \
    mysql-client \
    bash \
    && docker-php-ext-install pdo pdo_mysql mbstring zip gd intl bcmath opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Set environment
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PORT=8000

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Install Node dependencies and build assets
RUN if [ -f "package.json" ]; then npm ci --ignore-scripts || npm install; npm run build || true; fi

# Fix permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
