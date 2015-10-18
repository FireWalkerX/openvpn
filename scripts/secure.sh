#!/bin/bash

echo "[-] Securing the Server"

#Install Dependancies
echo "Installing Dependancies..."
yum install -y net-tools > /dev/null 2>&1
yum install -y perl > /dev/null 2>&1
yum install -y bind-utils > /dev/null 2>&1

# Configure Cron Jobs
echo "Configuring Cron Jobs..."
echo "00 00 * * * yum -y update" >> /tmp/securecronjob
crontab /tmp/securecronjob
rm -f /tmp/securecronjob

# Install ConfigServer Firewall
echo "Installing and Installing ConfigserverFirewall..."
wget http://www.configserver.com/free/csf.tgz  > /dev/null 2>&1
tar -xzf csf.tgz > /dev/null 2>&1
cd csf
bash install.sh > /dev/null 2>&1
cd ..
rm -rf csf/
rm -f csf.tgz
rm -f /etc/csf/csf.conf
cp -fp resources/csf.conf /etc/csf/csf.conf
csf -r  > /dev/null 2>&1

echo "[+] Server is Hardened!"
