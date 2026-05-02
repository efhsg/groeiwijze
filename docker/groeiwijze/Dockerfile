FROM php:8.2-fpm-alpine

# Install nginx, supervisor, and build dependencies
RUN apk add --no-cache nginx supervisor curl unzip

# Install PHP extensions
RUN docker-php-ext-install opcache ctype

# Create directories
RUN mkdir -p /var/www/html /var/www/private /var/www/vendor /run/nginx /var/log/supervisor /tmp/ratelimit

# Install composer using the official method (uses correct PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPMailer
WORKDIR /var/www
COPY composer.json .
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Copy nginx config
COPY nginx.conf /etc/nginx/http.d/default.conf

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Docker-specific contact form handler
COPY contact-submit.php /var/www/docker-contact-submit.php

# Copy PHP config generator script
COPY generate-config.sh /docker-entrypoint.d/generate-config.sh
RUN chmod +x /docker-entrypoint.d/generate-config.sh

# Copy custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set permissions
RUN chown -R www-data:www-data /var/www /tmp/ratelimit

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
