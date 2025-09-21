FROM php:8.2-fpm

RUN apt-get update && apt-get install -y nginx git zip unzip curl sqlite3 libsqlite3-dev libonig-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_sqlite mbstring

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader

COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD service nginx start && php-fpm
