FROM php:8.2-cli

# Install only essential dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy app
COPY . .
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chmod -R 755 storage bootstrap/cache

EXPOSE 8000
CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000"]
