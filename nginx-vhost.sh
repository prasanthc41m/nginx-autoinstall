#!/bin/sh
#
#Nginx and LetsEncrypt
#
read -p 'Enter Domain name: ' domain
apt-get update && apt -y install nginx
mkdir /var/www/$domain
cd /var/www/$domain
echo "<!DOCTYPE html><html><body><h1>$domain is working</h1></body></html>" > index.html
tail -13 /etc/nginx/sites-enabled/default > /etc/nginx/sites-enabled/demo.com
cd /etc/nginx/sites-enabled/
sed -i 's/#/ /g' demo.com
sed -i "s/example.com/$domain/g" demo.com
mv demo.com $domain
apt install -y python3-certbot-nginx && certbot --nginx 
/etc/init.d/nginx restart
