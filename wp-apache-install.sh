#!/bin/bash
apt-get update && apt-get upgrade
apt install tasksel -y
sudo tasksel install lamp-server

read -p 'Enter Domain name: ' domain
mkdir -p /var/www/html/$domain/public_html
chown -R www-data:www-data /var/www/html/$domain/
curl https://raw.githubusercontent.com/prasanthc41m/nginx-autoinstall/master/example.conf > /etc/apache2/sites-enabled/change.conf
cd /etc/apache2/sites-enabled/
sed -i "s/example.com/$domain/g" change.conf
read -p 'Enter 1st part of Domain name eg www.example: ' 1domain
read -p 'Enter last part of Domain name eg .com: ' 2domain
sed -i "s/example\.com/$1domain\.2domain/g" change.conf
mv change.conf $domain
sudo a2ensite $domain.conf
sudo apache2ctl -M
sudo a2enmod rewrite
sudo systemctl reload apache2
wget -O /var/www/html/$domain/public_html/ https://raw.githubusercontent.com/prasanthc41m/sitemaintenance/main/index.html

# Create MySQL database

read -p "Do you want to Install MySQL? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
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
wget -O	/var/www/html/$domain/public_html/db.php http://www.adminer.org/latest.php
fi

#Install wordpress

read -p "Do you want to Install Wordpress? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
rm /var/www/html/$domain/public_html/index*
cd /tmp/
wget http://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv latest.tar.gz wordpress-`date "+%Y-%m-%d"`.tar.gz
cp -R /var/www/html/src/wordpress/* /var/www/html/$domain/public_html/

cd /var/www/html/$domain/public_html
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php # Keep this file safe
mkdir uploads
grep -A 1 -B 50 'since 2.6.0' wp-config-sample.php > wp-config.php
curl https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
grep -A 50 -B 3 'Table prefix' wp-config-sample.php >> wp-config.php
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php
fi

# Install LetsEncrypt

read -p "Do you want to Install LetsEncrypt SSL? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
apt install -y python3-certbot-apache && certbot --apache 
fi
systemctl reload apache2
echo "Installtion Finished! "
