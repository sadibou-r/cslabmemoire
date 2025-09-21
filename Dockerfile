FROM php:8.2-cli

# Install system dependencies + MySQL
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    mysql-server \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY . .

# Set permissions
RUN chmod -R 755 storage bootstrap/cache
RUN composer run-script post-autoload-dump --no-dev

# MySQL setup script
RUN echo '#!/bin/bash\n\
service mysql start\n\
mysql -e "CREATE DATABASE IF NOT EXISTS laravel;"\n\
mysql -e "CREATE USER IF NOT EXISTS '\''laravel'\''@'\''localhost'\'' IDENTIFIED BY '\''password'\'';"\n\
mysql -e "GRANT ALL PRIVILEGES ON laravel.* TO '\''laravel'\''@'\''localhost'\'';"\n\
mysql -e "FLUSH PRIVILEGES;"\n\
' > /app/setup-mysql.sh && chmod +x /app/setup-mysql.sh

EXPOSE ${PORT:-8000}

# Start MySQL then Laravel
CMD ["sh", "-c", "/app/setup-mysql.sh && DB_HOST=localhost DB_DATABASE=laravel DB_USERNAME=laravel DB_PASSWORD=password php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
