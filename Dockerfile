FROM php:8.2-fpm

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libpq-dev

# Installer les extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql pgsql gd

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www

# Copier les fichiers du projet
COPY ./www/ /var/www/

# Copier le script d'entrée
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Donner les permissions d'exécution au script d'entrée
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Installer les dépendances du projet Laravel
RUN composer install

# Changer les permissions des dossiers de stockage
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
