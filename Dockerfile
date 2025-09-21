FROM php:8.2-cli

# Install only PDO MySQL (essentiel pour Laravel)
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN chmod -R 755 storage bootstrap/cache

EXPOSE 8000

# Simple startup
CMD ["sh", "-c", "php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=8000"]
