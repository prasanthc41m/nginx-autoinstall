#!/bin/sh
#
##Nginx and LetsEncrypt
#
read -p 'Enter Domain name: ' domain
apt-get update && apt -y install nginx nginx-full nginx-common
mkdir /var/www/$domain
cd /var/www/$domain
echo "<!DOCTYPE html><html><body><h1>Success!! $domain is working</h1></body></html>" > index.html
cat | curl https://raw.githubusercontent.com/prasanthc41m/nginx-install/master/default > /etc/nginx/sites-enabled/change.com
cd /etc/nginx/sites-enabled/
#sed -i 's/#/ /g' change.com
sed -i "s/example.com/$domain/g" change.com
mv change.com $domain
apt install -y python3-certbot-nginx && certbot --nginx 
service nginx restart
