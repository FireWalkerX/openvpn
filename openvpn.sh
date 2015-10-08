#!/bin/bash
# Setup RoundedSecurity VPN Server
# Writen by Johnny
# Automatic Provisioning for OpenVPN

#
# Setup paramaters
#
echo "These values are required for setup:"
echo -ne "Desired username: "
read superUser
echo -ne "OpenVPN Port(ex. 443): "
read port
echo "TLS/SSL Certificate Values"
echo -ne "Country: "
read country
echo -ne "Province/State: "
read province
echo -ne "City: "
read city
echo -ne "Organization: "
read organization
echo -ne "Email: "
read email
echo -ne "Organization Unit: "
read organizationUnit
echo -ne "Common Name(ex. vpn.roundedsecurity.com): "
read commonName
echo -ne "Client Device Name: "
read clientDevice

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
yum -y install openvpn easy-rsa > /dev/null 2>&1
yum -y install yum-utils > /dev/null 2>&1

# Setup User
adduser $superUser
echo "Specify Password for $superUser: "
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
echo "Installing and configuring OpenVPN"
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
echo "tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256" >> /etc/openvpn/server.conf 
echo "tls-version-min 1.2" >> /etc/openvpn/server.conf 
echo "tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0" >> /etc/openvpn/server.conf 

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
./build-ca --batch 
./build-key-server --batch server
./build-dh
cd /etc/openvpn/easy-rsa/keys
cp dh2048.pem ca.crt server.crt server.key /etc/openvpn
openvpn --genkey --secret ta.key

#Generate client keys and certificates
cd /etc/openvpn/easy-rsa
./build-key --batch $clientDevice

# Setup routing
yum install iptables-services -y  > /dev/null 2>&1
systemctl mask firewalld  > /dev/null 2>&1
systemctl enable iptables  > /dev/null 2>&1
systemctl stop firewalld  > /dev/null 2>&1
systemctl start iptables  > /dev/null 2>&1
iptables --flush  > /dev/null 2>&1
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
systemctl restart network.service  > /dev/null 2>&1

# Manage service
systemctl -f enable openvpn@server.service > /dev/null 2>&1
systemctl start openvpn@server.service > /dev/null 2>&1

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
echo "key-direction 1" >> /home/$superUser/$clientDevice.ovpn
echo "<tls-auth>" >> /home/$superUser/$clientDevice.ovpn
cat /etc/openvpn/easy-rsa/keys/ta.key >> /home/$superUser/$clientDevice.ovpn
echo "</tls-auth>" >> /home/$superUser/$clientDevice.ovpn

# Fix Permissions
chown -R $superUser:$superUser /home/$superUser

# sudo systemctl enable unbound.service
systemctl restart openvpn@server.service
