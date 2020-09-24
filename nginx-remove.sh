#/bin/sh
echo 'Uninstalling nginx and certbot'
service nginx stop
apt-get remove --purge nginx nginx-full nginx-common -y
rm -rf /etc/nginx
rm /usr/sbin/nginx
apt-get remove python-certbot-nginx -y
apt-get purge --auto-remove python-certbot-nginx -y
apt-get remove  python3-certbot-nginx -y 
apt-get purge --auto-remove python3-certbot-nginx -y
