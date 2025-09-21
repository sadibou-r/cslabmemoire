FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (only essential ones)
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    pcntl \
    bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first for better Docker layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application code
COPY . .

# Complete composer installation
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chmod -R 755 storage bootstrap/cache

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting Laravel application..."\n\
\n\
# Wait for database to be ready\n\
echo "Waiting for database connection..."\n\
until php artisan migrate:status > /dev/null 2>&1; do\n\
    echo "Database not ready, waiting..."\n\
    sleep 2\n\
done\n\
\n\
echo "Database connected successfully!"\n\
\n\
# Clear caches\n\
php artisan config:clear\n\
php artisan cache:clear\n\
\n\
# Cache configuration for production\n\
php artisan config:cache\n\
\n\
# Run migrations\n\
echo "Running migrations..."\n\
php artisan migrate --force\n\
\n\
# Run seeds (only if tables are empty to avoid duplicates)\n\
echo "Running seeds..."\n\
php artisan db:seed --force || echo "Seeds may have already been run"\n\
\n\
# Start the server\n\
echo "Starting server on port ${PORT:-8000}..."\n\
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8000}\n' > /usr/local/bin/start.sh

# Make startup script executable
RUN chmod +x /usr/local/bin/start.sh

# Expose port
EXPOSE 8000

# Use startup script
CMD ["/usr/local/bin/start.sh"]
