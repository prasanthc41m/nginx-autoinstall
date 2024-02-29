#!/bin/bash

# Install WordPress on a Debian/Ubuntu VPS - NGINX

# Install NGINX Server Block
read -p "Enter Domain name: " domain

# Update package lists and install packages
apt update && apt install -y nginx nginx-full nginx-common

# Create directory for website
mkdir /var/www/$domain

# Create a basic test page
echo "<!DOCTYPE html><html><body><h1>Success!! $domain is working</h1></body></html>" > /var/www/$domain/index.html

# Download NGINX configuration file
curl https://raw.githubusercontent.com/prasanthc41m/nginx-install/master/default > /etc/nginx/sites-available/$domain.conf

# Replace example.com with domain name in configuration file
sed -i "s/example.com/$domain/g" /etc/nginx/sites-available/$domain.conf

# Enable the new configuration file
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/

# Restart NGINX
systemctl restart nginx

# Install PHP and MySQL packages
apt install -y php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip mysql-server php-fpm php-mysql

# MySQL database setup
read -p "Enter your MySQL root password: " rootpass

# Read database details from user
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser [no single or double quotes, special characters]: " userpass

# Create database and user with secure connection
mysql -h localhost -u root -p$rootpass -e "CREATE DATABASE $dbname;"
mysql -h localhost -u root -p$rootpass -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';"
mysql -h localhost -u root -p$rootpass -e "GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;"
mysql -h localhost -u root -p$rootpass -e "FLUSH PRIVILEGES;"

# Download, unpack, and configure WordPress
cd /tmp/

wget -qO- https://wordpress.org/latest.tar.gz | tar -xzf -

# Move WordPress files to website directory
mv wordpress/* /var/www/$domain

# Change ownership of website directory to www-data
chown www-data:www-data -R /var/www/$domain

# Configure WordPress
cd /var/www/$domain

# Rename wp-config-sample.php and set permissions
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php

# Create uploads directory
mkdir uploads

# Configure wp-config.php with database details (replace with secure methods)
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php

# Install LetsEncrypt (optional)
read -p "Do you want to Install LetsEncrypt SSL? (y/N) " -n 1 -r
if [[ <span class="math-inline">REPLY \=\~ ^\[Yy\]</span> ]]; then
  apt install -y python3-certbot-nginx && certbot --nginx
fi

# Restart NGINX
systemctl restart
