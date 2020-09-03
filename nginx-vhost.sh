#!/bin/sh
#
#Nginx and LetsEncrypt
#
read -p 'Enter Domain name: ' domain
#apt-get update && apt -y install nginx
mkdir /var/www/$domain
cd /var/www/$domain
echo "<!DOCTYPE html><html><body><h1>Success!! $domain is working</h1></body></html>" > index.html
cat < EOF | tee -a /etc/nginx/sites-enabled/change.com
      ##Virtual Host
	server {
        listen 80;
        listen [::]:80;

        root /var/www/example.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name example.com www.example.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
EOF
cd /etc/nginx/sites-enabled/
sed -i 's/#/ /g' change.com
sed -i "s/example.com/$domain/g" change.com
#sed -i 's/try_files $uri $uri\/ =404/proxy_pass http:\/\/localhost:8008/g' change.com
mv change.com $domain
apt install -y python3-certbot-nginx && certbot --nginx 
service nginx restart
