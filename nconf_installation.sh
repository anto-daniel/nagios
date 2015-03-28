#!/bin/bash

apt-get update
apt-get install apache2 mysql-server mysql-client php5 libapache2-mod-php5 phpmyadmin -y
mysql -uroot -pmysql < create_database.sql
wget http://sourceforge.net/projects/nconf/files/nconf/1.3.0-0/nconf-1.3.0-0.tgz
mkdir -p /var/www/html
tar xvzf nconf-1.3.0-0.tgz -C /var/www/html
cd /var/www/html/nconf
chmod 777 config/
chmod 777 output/
chmod 777 static_cfg/
chmod 777 temp/
rm -rfv INSTALL INSTALL.php UPDATE UPDATE.php
chown nagios:www-data nagios
/etc/init.d/nagios reload
cd
wget http://forum.nconf.org/download/file.php?id=156&sid=1cba0f4c549f9dc42524ac476316be3f
mv file.php* nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch.zip
unzip nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch.zip
cp -rfv nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch /var/www/html/nconf
cd /var/www/html/nconf
patch -p0 --verbose < nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch
cp -rfv /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/nagios.cfg.orig
cp -rfv /usr/local/nagios/etc/nagios.cfg /var/www/html/nconf/static_cfg/
sed -i 's/^cfg_file/#cfg_file/g' /var/www/html/nconf/static_cfg/nagios.cfg
sed -i 's/^cfg_dir/#cfg_dir/g' /var/www/html/nconf/static_cfg/nagios.cfg
cat >> /var/www/html/nconf/static_cfg/nagios.cfg << EOM
cfg_dir=/usr/local/nagios/etc/global
cfg_dir=/usr/local/nagios/etc/Default_collector
EOM
chmod 777 /usr/local/nagios/var/nagios.log
chmod -R 777 /usr/local/nagios/etc/
sed -i "32s/^/define\(\'CHECK_STATIC_SYNTAX\', 0\);\n/" /var/www/html/nconf/config/nconf.php
cp -R /var/www/nconf/img /usr/local/nagios/share/images
/etc/init.d/nagios reload
