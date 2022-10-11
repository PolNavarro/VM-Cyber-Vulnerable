#!/bin/bash

#demanem el pass de root per poder crear les bases de dades més endevant
read -sp "Password: " rootpass

#instal·lació de LAMP
apt update
apt install -y apache2 libapache2-mod-php php php-mysql mariadb-server
apt-get install curl sudo -y

#Modifiquem la versió d'apache per la vulnerable
wget https://snapshot.debian.org/archive/debian-security/20211008T205652Z/pool/updates/main/a/apache2/apache2-bin_2.4.49-1~deb11u1_amd64.deb
wget https://snapshot.debian.org/archive/debian-security/20211008T205652Z/pool/updates/main/a/apache2/apache2-data_2.4.49-1~deb11u1_all.deb
wget https://snapshot.debian.org/archive/debian-security/20211008T205652Z/pool/updates/main/a/apache2/apache2-utils_2.4.49-1~deb11u1_amd64.deb
wget https://snapshot.debian.org/archive/debian-security/20211008T205652Z/pool/updates/main/a/apache2/apache2_2.4.49-1~deb11u1_amd64.deb
dpkg -i apache2-bin_2.4.49-1~deb11u1_amd64.deb
dpkg -i apache2-data_2.4.49-1~deb11u1_all.deb
dpkg -i apache2-utils_2.4.49-1~deb11u1_amd64.deb
dpkg -i apache2_2.4.49-1~deb11u1_amd64.deb

#Modifiquem la configuració de l'apache per activar totes les vulnerabilitats
sed -i 's/AllowOverride None/# AllowOverride None/g' /etc/apache2/apache2.conf
sed -i 's/denied/granted/' /etc/apache2/apache2.conf
echo ServerName 127.0.0.1 >> /etc/apache2/apache2.conf
a2enmod cgid
service apache2 restart

#instal·lem el phpmyadmin i el configurem com a alias del site per defecte del apache
export DEBIAN_FRONTEND=noninteractive
apt install -y php-mbstring php-xml
apt-get -yq install phpmyadmin
cat /etc/phpmyadmin/apache.conf | sed -i '28r/dev/stdin' /etc/apache2/sites-enabled/000-default.conf
/etc/init.d/apache2 restart

# Creem la BD per el wordpress
dbname='wordpress47897'
dbuser='user944289'
userpass='Pass4831290'
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "New MySQL database for wordpress is successfully created"

#Descarreguem i configurem la última versió del WordPress
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www --transform s/wordpress/html/
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
chmod 640 /var/www/html/wp-config.php
mkdir /var/www/html/uploads
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" /var/www/html/wp-config.php
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/html/wp-config.php
chown www-data: -R /var/www/html
rm /var/www/html/index.html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
IP=$(ip a | grep inet | grep 192 | awk '{print $2}' | awk '{ print substr( $0, 1, length($0)-3 ) }')
wp core install --allow-root --path=/var/www/html/ --url=$IP --title=Ciber --admin_user=test --admin_password=test --admin_email=YOU@YOURDOMAIN.com
service apache2 restart
echo -e "\nLa teva màquina amb la $IP està llesta, feliç hacking!\n"
