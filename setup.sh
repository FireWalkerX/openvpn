#!/bin/bash
# Setup RoundedSecurity VPN Server
# Writen by Johnny
# Automatic Provisioning for OpenVPN

#
# Setup paramaters
#
echo "These values are required for setup:"
echo "Desired username: "
read superUser
echo "OpenVPN Port(ex. 443): "
read port
echo "TLS/SSL Certificate Values"
echo "Country: "
read country
echo "Province/State: "
read province
echo "City: "
read city
echo "Organization: "
read organization
echo "Email: "
read email
echo "Organization Unit: "
read organizationUnit
echo "Common Name(ex. vpn.roundedsecurity.com): "
read commonName
echo "Client Device Name: "
read clientDevice

# Setup variables(Modify Accordingly)
# superUser="johnny"
# port="443"
# country="US"
# province="VA"
# city="Chesapeake"
# organization="RoundedSec"
# email="johnny@roundedsecurity.com"
# organizationUnit="RoundedSecurity"
# commonName="prod.roundedsecurity.com"
# clientDevice="client"

# Gets IP Automatically
ip=$(curl --silent https://duckduckgo.com/?q=what+is+my+ip | awk -F'Your IP address is ' '{print $2}' | awk '{print $1}')

#
# Install Prerequisits
#

# Update the server
echo "Updating the server..."
yum -y update > /dev/null 2>&1
yum -y upgrade > /dev/null 2>&1

# Required packages
echo "Installing required packages..."
yum -y install dos2unix-6.0.3-4.el7.x86_64 > /dev/null 2>&1
yum -y install epel-release.noarch > /dev/null 2>&1
yum -y install ntp > /dev/null 2>&1
yum install openvpn easy-rsa -y > /dev/null 2>&1
yum install yum-utils > /dev/null 2>&1

# Setup User
adduser $superUser
echo "Specify Password for $superUser"
passwd $superUser
gpasswd -a $superUser wheel

# Setup NTP
echo "Setting up network time protocol..."
sudo systemctl start ntpd > /dev/null 2>&1
sudo systemctl enable ntpd > /dev/null 2>&1

#
# Configure OpenVPN
#

# Install and configure OpenVPN
"Installing and configuring OpenVPN"
yum install openvpn easy-rsa -y > /dev/null 2>&1
\cp -f /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn
sed -i -e "s/;local a.b.c.d/local $ip/" /etc/openvpn/server.conf
sed -i -e "s/port 1194/port $port/" /etc/openvpn/server.conf
sed -i -e "s/;push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf
sed -i -e '/;push \"dhcp-option DNS 208.67.220.220\"/d' /etc/openvpn/server.conf
sed -i -e '/;push \"dhcp-option DNS 208.67.222.222\"/d' /etc/openvpn/server.conf
sed -i -e '200ipush "dhcp-option DNS 10.8.0.1"' /etc/openvpn/server.conf
sed -i -e "s/;group nobody/group nobody/" /etc/openvpn/server.conf
sed -i -e "s/;user nobody/user nobody/" /etc/openvpn/server.conf
echo "" >> /etc/openvpn/server.conf
echo "# Custom hardening by Rounded Security" >> /etc/openvpn/server.conf 
echo "cipher AES-256-CBC" >> /etc/openvpn/server.conf 
echo "auth SHA-256" >> /etc/openvpn/server.conf 
echo "tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256" >> /etc/openvpn/server.conf 
echo "tls-version-min 1.2" >> /etc/openvpn/server.conf 
echo "tls-auth /etc/openvpn/tls-auth.key 0" >> /etc/openvpn/server.conf 

# Create tls auth key
openvpn --genkey --secret /etc/openvpn/tls-auth.key

# Copy Key Files
mkdir -p /etc/openvpn/easy-rsa/keys
\cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa

# Configure vars
sed -i 's/export CA_EXPIRE=3650/export CA_EXPIRE=365/' /etc/openvpn/easy-rsa/vars
sed -i 's/export KEY_EXPIRE=3650/export KEY_EXPIRE=365/' /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_COUNTRY=\"US\"/export KEY_COUNTRY=\"$country\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_PROVINCE=\"CA\"/export KEY_PROVINCE=\"$province\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_CITY=\"SanFrancisco\"/export KEY_CITY=\"$city\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_ORG=\"Fort-Funston\"/export KEY_ORG=\"$organization\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_EMAIL=\"me@myhost.mydomain\"/export KEY_EMAIL=\"$email\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_OU=\"MyOrganizationalUnit\"/export KEY_OU=\"$organizationUnit\"/" /etc/openvpn/easy-rsa/vars
sed -i 's/export KEY_NAME="EasyRSA"/export KEY_NAME="server"/' /etc/openvpn/easy-rsa/vars
sed -i "s/export KEY_CN=openvpn.example.com/export KEY_CN=$commonName/" /etc/openvpn/easy-rsa/vars

# Copy OpenSSL configuration
\cp -f /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf

# Start generating keys and certificates
cd /etc/openvpn/easy-rsa
source ./vars
./clean-all
./build-ca
./build-key-server server
./build-dh
cd /etc/openvpn/easy-rsa/keys
cp dh2048.pem ca.crt server.crt server.key /etc/openvpn

#Generate client keys and certificates
cd /etc/openvpn/easy-rsa
./build-key $clientDevice

# Setup routing
yum install iptables-services -y
systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
systemctl restart network.service

# Manage service
systemctl -f enable openvpn@server.service
systemctl start openvpn@server.service

# Copy Client Certificates
cp /etc/openvpn/easy-rsa/keys/ca.crt /home/$superUser
cp /etc/openvpn/easy-rsa/keys/$clientDevice.crt /home/$superUser
cp /etc/openvpn/easy-rsa/keys/$clientDevice.key /home/$superUser

#Create Client Certificates
echo "client" > /home/$superUser/$clientDevice.ovpn
echo "dev tun" >> /home/$superUser/$clientDevice.ovpn
echo "proto udp" >> /home/$superUser/$clientDevice.ovpn
echo "remote $ip $port" >> /home/$superUser/$clientDevice.ovpn
echo "resolv-retry infinite" >> /home/$superUser/$clientDevice.ovpn
echo "nobind" >> /home/$superUser/$clientDevice.ovpn
echo "persist-key" >> /home/$superUser/$clientDevice.ovpn
echo "persist-tun" >> /home/$superUser/$clientDevice.ovpn
echo "comp-lzo" >> /home/$superUser/$clientDevice.ovpn
echo "verb 3" >> /home/$superUser/$clientDevice.ovpn
echo "tls-version-min 1.2" >> /home/$superUser/$clientDevice.ovpn
echo "script-security 1" >> /home/$superUser/$clientDevice.ovpn
echo "tls-auth 1" >> /home/$superUser/$clientDevice.ovpn
echo "<tls-auth>" >> /home/$superUser/$clientDevice.ovpn
cat /etc/openvpn/tls-auth.key >> /home/$superUser/$clientDevice.ovpn
echo "</tls-auth>" >> /home/$superUser/$clientDevice.ovpn
echo "key-direction 0" >> /home/$superUser/$clientDevice.ovpn
echo "verify-x509-name 'C=$country, ST=$province, L=$city, O=$organization, OU=$organizationUnit, CN=server, name=server, emailAddress=$email'" >> /home/$superUser/$clientDevice.ovpn
echo "<ca>" >> /home/$superUser/$clientDevice.ovpn
cat /etc/openvpn/easy-rsa/keys/ca.crt >> /home/$superUser/$clientDevice.ovpn
echo "</ca>" >> /home/$superUser/$clientDevice.ovpn
echo "<cert>" >> /home/$superUser/$clientDevice.ovpn
cat /etc/openvpn/easy-rsa/keys/$clientDevice.crt >> /home/$superUser/$clientDevice.ovpn
echo "</cert>" >> /home/$superUser/$clientDevice.ovpn
echo "<key>" >> /home/$superUser/$clientDevice.ovpn
cat /etc/openvpn/easy-rsa/keys/$clientDevice.key >> /home/$superUser/$clientDevice.ovpn
echo "</key>" >> /home/$superUser/$clientDevice.ovpn

# Fix Permissions
chown -R $superUser:$superUser /home/$superUser

#
# Configure Unbound
#
yum install unbound -y
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.original
/etc/unbound/unbound.conf


Interface 10.8.0.1
do-ip4: yes
do-udp: yes
do-tcp: yes
logfile: /var/log/unbound
hide-identity: yes
hide-version: yes
access-control: 10.8.0.1/32 allow
unbound-checkconf /etc/unbound/unbound.conf
# systemctl start unbound.service
# sudo systemctl enable unbound.service
unbound-control dump_cache > /tmp/DNS_cache.txt
