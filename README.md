# Nginx Virtual Host

### Nginx virtual host with free ssl for Debian

Point the DNS for your domain to server IP. Copy below simple commands to terminal and insert below details to complete installation.

``` 
sudo su
wget https://raw.githubusercontent.com/prasanthc41m/nginx-install/master/nginx-vhost.sh -O - | bash 
```
Insert domain name of the wesite to access using https://example.com

# Nginx Reverse Proxy

### Nginx reverse proxy with free ssl for Debian

Point the DNS for your domain to server IP. Copy below simple commands to terminal and insert below details to complete installation.

``` 
sudo su
wget https://raw.githubusercontent.com/prasanthc41m/nginxrproxy/master/nginx-reverseproxy.sh -O - | bash 
```
Insert domain name and port number of the server to access using https://example.com instead of http://127.0.0.1:8080
 
