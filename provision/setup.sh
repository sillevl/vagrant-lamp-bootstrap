#!/usr/bin/env bash

echo "Provisioning virtual machine..."

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='dev'


# update / upgrade
echo "update and upgrade system"
sudo apt-get update &> /dev/null
sudo apt-get -y upgrade &> /dev/null

# install apache 2.5 and php 5.5
echo "installing apache2"
sudo apt-get install -y apache2 &> /dev/null
echo "installing php5"
sudo apt-get install -y php5 &> /dev/null

# install mysql and give password to installer
echo "configuring mysql"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
echo "installing mysql"
sudo apt-get -y install mysql-server &> /dev/null
sudo apt-get -y install php5-mysql &> /dev/null

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
echo "configuring phpmyadmin"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
echo "installing phpmyadmin"
sudo apt-get -y install phpmyadmin &> /dev/null

# setup hosts file
echo "Creating apache configuration"
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/"
    <Directory "/var/www/html/">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" &> /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
echo "enabling mod_rewrite"
sudo a2enmod rewrite &> /dev/null

# restart apache
echo "restarting apache"
service apache2 restart &> /dev/null

# install git
echo "installing git"
sudo apt-get -y install git &> /dev/null


echo "Finished provisioning."
