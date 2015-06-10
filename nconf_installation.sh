#!/bin/bash

ddir=`pwd`
apt-get update
apt-get install apache2 mysql-server mysql-client php5 libapache2-mod-php5 phpmyadmin zip unzip -y
echo "Downloading and extracting nconf . . . . "
wget http://sourceforge.net/projects/nconf/files/nconf/1.3.0-0/nconf-1.3.0-0.tgz
apache_dir=`cat /etc/apache2/sites-{enabled,available}/000-default.conf | grep -i 'DocumentRoot' | awk '{print $2}' | head -1 2>error`
nconfdir="$apache_dir/nconf"
tar xvzf nconf-1.3.0-0.tgz -C $apache_dir
chown -R www-data:www-data $nconfdir
chmod -R 777 $nconfdir
cd $nconfdir
chmod 777 config/
chmod 777 output/
chmod 777 static_cfg/
chmod 777 temp/
#chown -R nagios:www-data nagios
/etc/init.d/nagios reload
cd
wget http://forum.nconf.org/download/file.php?id=156&sid=1cba0f4c549f9dc42524ac476316be3f
pfile=`ls -1 file.php* | tail -1`
mv -v $pfile nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch.zip
unzip nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch.zip
cp -rfv nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch $apache_dir/nconf
cd $apache_dir/nconf
patch -p0 --verbose < nconf-1.3.0-0_not_used_advanced_services_wont_be_written.patch
echo "Creating Database for nconf . . . ."
mysql -uroot -pmysql < ~/nagios/create_database.sql
cp -rfv /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/nagios.cfg.orig
cp -rfv /usr/local/nagios/etc/nagios.cfg $nconfdir/static_cfg/
sed -i 's/^cfg_file/#cfg_file/g' $nconfdir/static_cfg/nagios.cfg
sed -i 's/^cfg_dir/#cfg_dir/g' $nconfdir/static_cfg/nagios.cfg
cat >> $nconfdir/static_cfg/nagios.cfg << EOM
cfg_dir=/usr/local/nagios/etc/global
cfg_dir=/usr/local/nagios/etc/Default_collector
EOM
chmod 777 /usr/local/nagios/var/nagios.log
chmod -R 777 /usr/local/nagios/etc/
cp -dpR $nconfdir/config.orig/* $nconfdir/config
sed -ie "10s/NConf/nconf/g" $nconfdir/config/mysql.php
sed -ie "12s/link2db/nconf/g" $nconfdir/config/mysql.php
sed -ie "11s/^/#/g" $nconfdir/config/nconf.php
sed -ie "16s|^|define('NCONFDIR', \"$nconfdir\")\;|g" $nconfdir/config/nconf.php
sed -ie "23s|/var/www/nconf/bin/nagios|/usr/local/nagios/bin/nagios|g" $nconfdir/config/nconf.php
#sed -ie "32s/^/define\(\'CHECK_STATIC_SYNTAX\', 0\);\n/" $nconfdir/config/nconf.php
mysql -unconf -pnconf nconf < INSTALL/create_database.sql
rm -rfv INSTALL INSTALL.php UPDATE UPDATE.php
cp -R $nconfdir/img /usr/local/nagios/share/images
chown nagios:www-data /usr/local/nagios/bin/nagios
tail -2 $nconfdir/static_cfg/nagios.cfg | awk -F= '{print $2}' | xargs -I {} mkdir -p {}
mv -v $nconfdir/static_cfg/nagios.cfg /usr/local/nagios/etc
/etc/init.d/nagios reload
cd && rm -rfv $pfile $ddir/nconf-1.3.0-0.tgz $HOME/file.php*
