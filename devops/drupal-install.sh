#!/bin/sh
# Bash script for provisioning a vagrant box for FoxConnect
# first check to see if provisioning already has occurred
# if there is an apache2 dir you have already run this
if [ -d "/etc/apache2" ]; then
  exit 0;
fi
# otherwise, run through provisioning
sudo su
apt-get update

# prevent dialogs asking config questions, just use defaults
export DEBIAN_FRONTEND=noninteractive
#apt-get -q -y install mysql-server mysql-client
# set root user password to root
#mysqladmin -u root password root

# install additional packages
#apt-get -y install apache2
apt-get -y install php5 libapache2-mod-php5
apt-get -y install php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-tidy php5-xmlrpc php5-dev pv make
pecl install xdebug
/etc/init.d/apache2 restart

# add user to www-data group
adduser vagrant www-data

# Install drush
# extra steps to make sure drush has proper write perms
pear channel-discover pear.drush.org
pear install drush/drush
sudo drush --version
sudo chown -R vagrant:vagrant ~/.drush

# add custom drupal apache websites
echo "<VirtualHost *:80>
	ServerName sandbox.com
	ServerAlias www.sandbox.com
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/drupal
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/sandbox

#echo "<VirtualHost *:80>
#	ServerAlias www.drupal-seven.com
#	ServerAdmin webmaster@localhost
#	DocumentRoot /var/www/htdocs/drupal-seven
#	<Directory />
#		Options FollowSymLinks
#		AllowOverride None
#	</Directory>
#	<Directory /var/www/>
#		Options Indexes FollowSymLinks MultiViews
#		AllowOverride All
#		Order allow,deny
#		allow from all
#	</Directory>
#</VirtualHost>" > /etc/apache2/sites-available/drupal-seven

/etc/init.d/apache2 restart

# enable mod rewrite
a2enmod rewrite
# enable new websites
a2ensite sandbox

# add xdebug ini file for apache2 and php cli
echo "zend_extension=/usr/lib/php5/20100525/xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_mode=req
xdebug.remote_port=9000
xdebug.remote_handler=dbgp
xdebug.remote_autostart=1
xdebug.remote_log=/tmp/xdebug.log" > /etc/php5/conf.d/xdebug.ini

/etc/init.d/apache2 restart

# create db and load database, use pv for progress meter
#mysqladmin -uroot -proot create drupal-six

#echo "Importing the databases. This could take a few minutes.";
#pv /vagrant/devops/drupal-six.sql.gz | gunzip | mysql -uroot -proot drupal-six
#pv /vagrant/devops/drupal-seven.sql.gz | gunzip | mysql -uroot -proot drupal-seven

echo "Done provisioning Drupal Sandbox VM. Please see README.txt for additional steps.";

# return to command prompt
exit 0