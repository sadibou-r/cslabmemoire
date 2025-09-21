FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    zip \
    unzip \
    curl \
    sqlite3 \
    libsqlite3-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application files
COPY . .

# Set up directories and permissions
RUN mkdir -p /app/database \
    /app/storage/app/public/images \
    /app/storage/logs \
    /app/storage/framework/cache \
    /app/storage/framework/sessions \
    /app/storage/framework/views && \
    touch /app/database/database.sqlite && \
    chown -R www-data:www-data storage bootstrap/cache database && \
    chmod -R 775 storage bootstrap/cache database

# Complete Composer setup
RUN composer run-script post-autoload-dump --no-dev

# Ensure .env exists and APP_KEY is set
RUN if [ ! -f .env ]; then cp .env.example .env; fi && \
    if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env; then \
      php artisan key:generate --force; \
    fi

# Nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Expose port (Railway will map $PORT)
EXPOSE 8080

# Start PHP-FPM and Nginx, with log tail for debugging
CMD php-fpm -D && nginx -g "daemon off;" && tail -f storage/logs/laravel.log
