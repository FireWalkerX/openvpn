#!/bin/bash

source vars.conf

#Install Dependancies
yum install -y net-tools > /dev/null 2>&1
yum install -y perl > /dev/null 2>&1
yum install -y bind-utils > /dev/null 2>&1
#yum install perl-libwww-perl net-tools perl-LWP-Protocol-https > /dev/null 2>&1

#Update adblocking daily
\cp -f scripts/adblocker.sh /opt/adblocker.sh

# Configure Cron Jobs
echo "00 00 * * * yum -y update" >> /tmp/securecronjob
echo "00 00 * * * /bin/bash /opt/adblocker.sh > /dev/null 2>&1" >> /tmp/securecronjob
crontab /tmp/securecronjob
rm -f /tmp/securecronjob

# Install ConfigServer Firewall
#wget http://www.configserver.com/free/csf.tgz  > /dev/null 2>&1
#tar -xzf csf.tgz > /dev/null 2>&1
#cd csf
#bash install.sh > /dev/null 2>&1
#cd ..
#rm -rf csf/
#rm -f csf.tgz
#rm -f /etc/csf/csf.conf
#cp -fp resources/csf.conf /etc/csf/csf.conf
#csf -r  > /dev/null 2>&1
#useradd csf

# Setup User
adduser $superUser
echo -e "$password" | passwd --stdin $superUser > /dev/null 2>&1
gpasswd -a $superUser wheel > /dev/null 2>&1

echo "[+] Server hardening complete"
