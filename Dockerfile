FROM php:8.2-cli

# Install system dependencies including SQLite development files
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    sqlite3 \
    libsqlite3-dev \
    pkg-config \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (added mbstring and other Laravel essentials)
RUN docker-php-ext-install pdo pdo_sqlite mbstring

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files first
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application
COPY . .

# Create SQLite database and set permissions
RUN mkdir -p /app/database && \
    touch /app/database/database.sqlite && \
    mkdir -p /app/storage/app/public/images && \
    mkdir -p /app/storage/logs && \
    mkdir -p /app/storage/framework/{cache,sessions,views} && \
    chmod -R 775 storage bootstrap/cache database && \
    chown -R www-data:www-data storage bootstrap/cache database

# Complete composer setup
RUN composer run-script post-autoload-dump --no-dev

# Create .env file first, then generate application key
RUN echo "APP_NAME=Laravel" > .env && \
    echo "APP_ENV=production" >> .env && \
    echo "APP_DEBUG=false" >> .env && \
    echo "APP_URL=https://\${RAILWAY_PUBLIC_DOMAIN:-localhost}" >> .env && \
    echo "LOG_CHANNEL=stderr" >> .env && \
    echo "LOG_LEVEL=error" >> .env && \
    echo "" >> .env && \
    echo "DB_CONNECTION=sqlite" >> .env && \
    echo "DB_DATABASE=/app/database/database.sqlite" >> .env && \
    echo "" >> .env && \
    echo "BROADCAST_DRIVER=log" >> .env && \
    echo "CACHE_DRIVER=file" >> .env && \
    echo "FILESYSTEM_DISK=local" >> .env && \
    echo "QUEUE_CONNECTION=sync" >> .env && \
    echo "SESSION_DRIVER=file" >> .env && \
    echo "SESSION_LIFETIME=120" >> .env && \
    echo "APP_KEY=" >> .env && \
    php artisan key:generate --force

# Railway uses PORT environment variable
EXPOSE $PORT

# Fixed startup command with proper port handlingy
CMD ["sh", "-c", "php artisan config:cache && php artisan route:cache && php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
