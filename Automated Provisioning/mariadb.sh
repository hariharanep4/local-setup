#! /bin/bash
DATABASE_PASSWORD=admin123
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y

# start and enable mariadb service

sudo systemctl start mariadb
sudo systemctl enable mariadb

git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git

# restore the dump file for the application

sudo mysqladmin -u root password "$DATABASE_PASSWORD"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASSWORD') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "grant all privileges on accounts.* to 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "grant all privileges on accounts.* to 'admin'@'%' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASSWORD" accounts < vprofile-project/src/main/resources/db/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASSWORD" -e "FLUSH PRIVILEGES"

# Restart MariaDB server

sudo systemctl restart mariadb

# Start firewall and allow the mariadb to access from port 3306

sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb