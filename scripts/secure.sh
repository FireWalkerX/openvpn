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

# Setup User
adduser $superUser
echo -e "$password" | passwd --stdin $superUser > /dev/null 2>&1
gpasswd -a $superUser wheel > /dev/null 2>&1

# Secure ssh
sed -i -e "s/#Port 22/Port 222/" /etc/ssh/sshd_config
sed -i -e "s/#ServerKeyBits 1024/ServerKeyBits 2048/" /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
systemctl restart sshd

# Setup firewalld
systemctl start firewalld > /dev/null 2>&1
systemctl enable firewalld > /dev/null 2>&1
firewall-cmd --add-service openvpn > /dev/null 2>&1
firewall-cmd --permanent --add-service openvpn > /dev/null 2>&1
firewall-cmd --add-masquerade > /dev/null 2>&1
firewall-cmd --permanent --add-masquerade > /dev/null 2>&1
firewall-cmd --permanent --zone=public --add-port=53/udp > /dev/null 2>&1
firewall-cmd --permanent --zone=public --add-port=443/tcp > /dev/null 2>&1
firewall-cmd --permanent --zone=public --add-port=443/udp > /dev/null 2>&1
# Alternative ssh port
firewall-cmd --permanent --zone=public --add-port=222/tcp > /dev/null 2>&1
firewall-cmd --reload > /dev/null 2>&1

# SELinux test and rules
if [[ $(getenforce) = Enforcing ]] || [[ $(getenforce) = Permissive ]]; then
  yum install policycoreutils-python -y
  semanage port -a -t ssh_port_t -p tcp 222
  semanage port -m -t openvpn_port_t -p tcp 443
  semanage port -a -t openvpn_port_t -p udp 443
fi
