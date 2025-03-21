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
    libpq-dev \
    libzip-dev \
    libicu-dev \
    g++

# Installer les extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_pgsql pgsql gd zip intl calendar

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installer Node.js et npm
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Vérifier l'installation de Node.js et npm
RUN node -v && npm -v

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

# Installer les dépendances npm du projet
RUN npm install

# Changer les permissions des dossiers de stockage et de cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000

# Commande d'entrée par défaut
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]
