#!/bin/bash


apt-get install gcc gawk openssl make libssl-dev
wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
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

tar xvzf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install-plugin
make install-daemon
make install-daemon-config
echo "Enter Nagios Monitoring Server IP Address: "
read nag_ip
sed -ie "/allowed_hosts/ s/$/,${nag_ip}/" /usr/local/nagios/etc/nrpe.cfg
cp init-script.debian /etc/init.d/nrpe
chmod 755 /etc/init.d/nrpe
/etc/init.d/nrpe start
update-rc.d nrpe defaults
