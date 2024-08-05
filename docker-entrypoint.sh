#!/bin/sh

# Générer la clé de l'application
php artisan key:generate

# Exécuter les migrations
php artisan migrate

# Démarrer php-fpm
php-fpm
