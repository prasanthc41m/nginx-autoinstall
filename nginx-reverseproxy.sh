#!/bin/sh
#
#Nginx reverse proxy and LetsEncrypt
#
read -p 'Enter domain name: ' domain

apt-get update && apt -y install nginx
systemctl enable nginx.service && systemctl start nginx.service
cat << EOF | tee -a /tmp/$domain
server {
	listen 80;
	listen [::]:80;

	server_name example.com;

#	root /var/www/example.com;
#	index index.html;

	location / {
		try_files $uri $uri/ =404;
	}
}
EOF
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
