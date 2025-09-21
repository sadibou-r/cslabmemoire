FROM php:8.2-cli

# Install dependencies
RUN apt-get update && apt-get install -y git zip unzip curl && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chmod -R 755 storage bootstrap/cache

# Simple startup - sans migrations pour tester
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
