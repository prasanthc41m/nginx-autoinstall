#!/bin/bash
#
# Install WordPress on a Debian/Ubuntu VPS - NGINX
#
# Install NGINX SERVER BLOCK 
#
read -p 'Enter Domain name: ' domain
apt-get update && apt -y install nginx nginx-full nginx-common
mkdir /var/www/$domain
cd /var/www/$domain
echo "<!DOCTYPE html><html><body><h1>Success!! $domain is working</h1></body></html>" > index.html
curl https://raw.githubusercontent.com/prasanthc41m/nginx-install/master/default > /etc/nginx/sites-enabled/change.com
cd /etc/nginx/sites-enabled/
sed -i "s/example.com/$domain/g" change.com
mv change.com $domain
#apt install -y python3-certbot-nginx && certbot --nginx 
#
sleep 05 ; apt -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip mysql-server php-fpm php-mysql mysql-community-server mysql-client mysql-community-client
systemctl restart php7.2-fpm
# Installs wordpress in /var/www/mywebsite.com/, and configures NGINX
# Create MySQL database
read -p "Enter your MySQL root password: " rootpass
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser [no single or double quotes, special characters]:" userpass
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "Database created...\n"
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "Database user created...\n"
echo "GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;" | mysql -u root -p$rootpass
echo "Privileges granted...\n"
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "New MySQL database is successfully created"
# Download, unpack and configure WordPress
#read -r -p "Enter your WordPress Domain name? [e.g. mywebsite.com]: " domain
#mkdir /var/www/$domain 
cd /tmp/
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf -
cp -r /tmp/wordpress/* /var/www/$domain 
chown www-data: -R /var/www/$domain/ # Give server ownership for now
cd /var/www/$domain/
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php # Keep this file safe
mkdir uploads
grep -A 1 -B 50 'since 2.6.0' wp-config-sample.php > wp-config.php
curl https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
grep -A 50 -B 3 'Table prefix' wp-config-sample.php >> wp-config.php
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php
#chown $USER:www-data -R * # Change user to current, group to server
chown www-data:www-data -R * # Change user to server, group to server
find . -type d -exec chmod 755 {} \; # Change directory permissions rwxr-xr-x
find . -type f -exec chmod 644 {} \; # Change file permissions rw-r--r--
chown www-data:www-data wp-content # Let server be owner of wp-content
# Install LetsEncrypt
read -p "Do you want to Install LetsEncrypt SSL? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
apt install -y python3-certbot-nginx && certbot --nginx 
fi
service nginx restart
echo "Installtion Finished! "
rm -rf *.sh.*
