#!/bin/bash


apt-get update && apt-get install gcc gawk openssl make libssl-dev expect -y
echo "Downloading nrpe plugin . . ."
cd /tmp
np_cmd=`wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz 2> /tmp/np_log`
d_st=`echo $?`
if [[ $d_st -ne 0 ]]; then
  echo "Unable to download nagios plugin. Exiting...."
  exit 1
fi
tar xvzf nagios-plugins-2.0.3.tar.gz
cd nagios-plugins-2.0.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules --enable-extra-opts
make
make install
cmd=`grep nagios /etc/passwd`
st=`echo $?`

if [[ $st -eq 0 ]]; then
  echo "User nagios already exists"
else
  echo "Creating new user \"nagios\""
  useradd nagios
  cat > nagios_passwd.sh << EOM
#!/usr/bin/expect -f
spawn passwd nagios
expect "Enter new UNIX password: "
send "nagios\r"
expect "Retype new UNIX password: "
send "nagios\r"
expect eof
EOM
  chmod u+x nagios_passwd.sh
  ./nagios_passwd.sh
fi
echo "Downloading nrpe package . . ."
nconf_cmd=`wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz 2> /tmp/nconf_log`
n_st=`echo $?`
if [[ $n_st -ne 0 ]]; then
 echo "Unable to download nrpe. Exiting . . ."
 exit 1
fi 
tar xvzf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu --enable-command-args
make all
make install-plugin
make install-daemon
make install-daemon-config
echo "Enter Nagios Monitoring Server IP Address: "
read nag_ip
sed -ie "/allowed_hosts/ s/$/,${nag_ip}/" /usr/local/nagios/etc/nrpe.cfg
sed -ie "/dont_blame_nrpe/ s/0/1/" /usr/local/nagios/etc/nrpe.cfg
cp init-script.debian /etc/init.d/nrpe
chmod 755 /etc/init.d/nrpe
/etc/init.d/nrpe start
update-rc.d nrpe defaults
