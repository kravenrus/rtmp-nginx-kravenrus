#!/bin/bash
clear
# Source progress bar
#source ./progress_bar.sh
# Make sure that the progress bar is cleaned up when user presses ctrl+c
#enable_trapping
# Create progress bar
#setup_scroll_area
####################################################################
sudo apt update
sudo apt install -y apache2 apache2-utils
cat apache2.conf > /etc/apache2/apache2.conf
cat example.com.conf > /etc/apache2/sites-available/example.com.conf
# htpasswd -c /etc/apache2/.htpasswd admin
sudo a2enmod rewrite
sudo a2ensite example.com.conf
sudo a2dissite 000-default.conf
sudo a2dissite default-ssl.conf
mkdir -p /var/www/example.com/public_html
# cat index.html > /var/www/example.com/public_html/index.html
# cat index.php > /var/www/example.com/public_html/index.php
chown -R www-data:www-data /var/www
####################################################################
sudo apt install -y mariadb-server
sudo service mysql start
mysql_secure_installation
mariadb < mariadb.sql
sleep 5
sudo service mysql stop
####################################################################
sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-gd php-dom
cat dir.conf > /etc/apache2/mods-enabled/dir.conf
####################################################################
sudo apt install -y pwgen
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.zip
unzip phpMyAdmin-5.1.0-all-languages.zip
mv phpMyAdmin-5.1.0-all-languages/ /usr/share/phpmyadmin
mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
cat config.inc.php > /usr/share/phpmyadmin/config.inc.php
sed -i -e 's/SECRET_KEY/'$(pwgen -s 32 1)'/' /usr/share/phpmyadmin/config.inc.php
sudo service mysql start
mariadb < /usr/share/phpmyadmin/sql/create_tables.sql
sleep 5
sudo service mysql stop
cat phpmyadmin.conf > /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf
sudo service mysql restart
sudo service apache2 restart
####################################################################
sudo apt install -y gnupg2 net-tools curl
# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt -y install postgresql-13 postgresql-client-13
sudo -u postgres psql -f postgres.sql
cat postgresql.conf > /etc/postgresql/13/main/postgresql.conf
cat pg_hba.conf > /etc/postgresql/13/main/pg_hba.conf
sudo service postgresql restart
####################################################################
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
sudo apt update
sudo apt install -y pgadmin4
sudo /usr/pgadmin4/bin/setup-web.sh
