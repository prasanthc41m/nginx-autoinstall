#!/bin/sh
#
#Nginx reverse proxy and LetsEncrypt
#
read -p 'Enter domain name: ' domain

apt-get update && apt -y install nginx nginx-full nginx-common
systemctl enable nginx.service && systemctl start nginx.service
curl https://raw.githubusercontent.com/prasanthc41m/nginx-install/master/default | head -n 13 > /tmp/$domain
mv /tmp/$domain /tmp/file.txt
cd /tmp
sed -i "s/example.com/$domain/g" file.txt
read -p 'Enter server port number: ' port
sed -i "s/try_files $uri $uri\/ =404/proxy_pass http:\/\/127.0.0.1:port/g" file.txt
sed -i "s/port/$port/g" file.txt
cat file.txt
mv file.txt /etc/nginx/sites-enabled/$domain
apt install -y python3-certbot-nginx && certbot --nginx 
systemctl restart nginx.service
