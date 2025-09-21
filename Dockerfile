FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# SQLite est déjà inclus dans php:8.2-fpm
RUN docker-php-ext-enable pdo_sqlite

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
    chmod -R 755 storage bootstrap/cache database

# Complete composer setup
RUN composer run-script post-autoload-dump --no-dev

EXPOSE ${PORT:-8000}

# Start with SQLite
CMD ["sh", "-c", "php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
