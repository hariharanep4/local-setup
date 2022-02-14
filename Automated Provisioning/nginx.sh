#! /bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y

cat <<EOT > vproapp
upstream vproapp {
    server tomcat:8080;
}

server {
    listen 80;
location / {
    proxy_pass http://vproapp;
}
}
EOT

sudo mv vproapp /etc/nginx/sites-available/vproapp
sudo rm -rf /etc/ngin/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# start nginx service and firewall

sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx