#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.0 libapache2-mod-php8.0 php8.0-mysql php8.0-curl \
  php8.0-curl php8.0-intl php8.0-zip php8.0-imap php8.0-gd php8.0-xml \
  php8.0-mbstring php8.0-ldap zlib1g-dev libxml2-dev nodejs npm

sudo a2enmod rewrite
# Setup /etc/apache2/sites-available/SuiteCRM.conf
# sudo systemctl restart apache2

sudo npm install -g yarn @angular/cli

# https://getcomposer.org/download/

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer

# sudo cp -r /vagrant/SuiteCRM /var/www/html/SuiteCRM

function set_permissions() {
    cd /var/www/html
    sudo find . -type d -not -perm 2755 -exec chmod 2755 {} \;
    sudo find . -type f -not -perm 0644 -exec chmod 0644 {} \;
    sudo find . ! -user www-data -exec chown www-data:www-data {} \;
}

set_permissions

cd /var/www/html/SuiteCRM
sudo -u www-data yarn install
sudo -u www-data yarn run build:common
sudo -u www-data yarn run build:core
sudo -u www-data yarn run build:shell


sudo -u www-data composer update
sudo -u www-data composer install

sudo -u www-data php vendor/bin/pscss -s compressed ./public/legacy/themes/suite8/css/Dawn/style.scss > /tmp/style.css
sudo -u www-data cp /tmp/style.css ./public/legacy/themes/suite8/css/Dawn/style.css

set_permissions

sudo -u www-data chmod +x bin/console

# https://dzone.com/articles/step-by-step-guide-to-setting-up-a-local-suitecrm
# Update php.ini upload_max_filesize to 10M