#!/bin/bash

# Check if the script is being run as root, if not, run as root
if [[ "$(id -u)" -ne 0 ]]; then
    sudo -E "$0" "$@"
    exit
fi

# software properties common
apt-get install -y software-properties-common

# update packages 
apt-get update

# upgrade packages
apt-get upgrade -y

# install apache2
apt-get install -y apache2

# enable and start apache2
systemctl enable apache2
systemctl start apache2

# install mysql
apt-get install -y mysql-server

# secure mysql installation automatically
debconf-set-selections <<< 'mysql-server mysql-server/root_password password 53669'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 53669'

# enable mysql and start mysql
systemctl enable mysql
systemctl start mysql

# add php repository
add-apt-repository -y ppa:ondrej/php

# update packages 
apt-get update -y

# Install additional php modules that Laravel requires
apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-bcmath php-curl php-zip unzip -y

# enable php
a2enmod php8.2

# configure php 
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini

# restart apache2
systemctl restart apache2

# install composer and move the .phar file to /usr/local/bin/composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# create a new configuration file called laravel.conf
cat << EOF | tee /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
    ServerAdmin kbneyo55@gmail.com
    ServerName 192.168.56.40
    ServerAlias www.laravel.local
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# enable site
a2enmod rewrite
a2ensite laravel.conf

# restart server to apply changes
systemctl restart apache2

# configure Mysql with the cat command
cat << EOF | mysql -u root -p=53669
CREATE DATABASE laravel;
GRANT ALL ON laravel_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF

# install git
apt-get install -y git

# clone the laravel project
cd /var/www/ || exit
git clone https://github.com/laravel/laravel.git

# cd into the directory of your cloned repository
cd /var/www/laravel || exit

# run composer to get all dependencies for this project with no dev
composer install --no-dev --no-interaction --optimize-autoloader

# update composer
composer update --no-dev --no-interaction --optimize-autoloader

# create an environment file
cp .env.example .env

# Define the new database password
NEW_DB_PASSWORD="53669"

# Update the DB_PASSWORD in the .env file using sed
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$NEW_DB_PASSWORD/" .env

#permissions for the directories
chown -R www-data.www-data /var/www/laravel
chmod -R 755 /var/www/laravel
chmod -R 755 /var/www/laravel/storage
chmod -R 755 /var/www/laravel/bootstrap/cache

# php key gen
php artisan key:generate

# clear config cache
php artisan config:cache

# migrate tables
php artisan migrate --force

# restart apache2
systemctl restart apache2

echo "Done! Laravel is now installed and ready!"