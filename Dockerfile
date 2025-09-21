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
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set environment variables for SQLite
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/app/database/database.sqlite
ENV APP_ENV=production
ENV APP_DEBUG=true
ENV LOG_CHANNEL=stderr
ENV APP_KEY=base64:VOTRE_CLE_GENEREE_ICI

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
    chmod -R 755 storage bootstrap/cache database

# Optionnel: Ajouter des images de test
# COPY test-images/* /app/storage/app/public/images/

# Complete composer setup
RUN composer run-script post-autoload-dump --no-dev

# Generate application key and store it
RUN php artisan key:generate --no-interaction --force

EXPOSE ${PORT:-8000}

# Simplified CMD test since environment variables are already set
CMD ["sh", "-c", "php artisan config:clear && php artisan cache:clear && php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
