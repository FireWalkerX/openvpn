#!/bin/bash
# Created by Rounded Security
# Setup client certificates for OpenVPN

source vars.conf

#Generate client keys and certificates
cd /etc/openvpn/easy-rsa
source ./vars > /dev/null 2>&1
./build-key --batch $clientDevice  > /dev/null 2>&1

#Create Client Certificates
echo "client" > /home/$superUser/$clientDevice.ovpn
echo "dev tun" >> /home/$superUser/$clientDevice.ovpn
echo "proto udp" >> /home/$superUser/$clientDevice.ovpn
echo "remote $ip $port" >> /home/$superUser/$clientDevice.ovpn
echo "resolv-retry 20" >> /home/$superUser/$clientDevice.ovpn
echo "nobind" >> /home/$superUser/$clientDevice.ovpn
echo "persist-key" >> /home/$superUser/$clientDevice.ovpn
echo "persist-tun" >> /home/$superUser/$clientDevice.ovpn
echo "comp-lzo" >> /home/$superUser/$clientDevice.ovpn
echo "verb 3" >> /home/$superUser/$clientDevice.ovpn
echo "tls-version-min 1.2" >> /home/$superUser/$clientDevice.ovpn
echo "script-security 1" >> /home/$superUser/$clientDevice.ovpn
echo "cipher AES-256-CBC" >> /home/$superUser/$clientDevice.ovpn
echo "auth SHA512" >> /home/$superUser/$clientDevice.ovpn
echo "remote-cert-eku "TLS Web Server Authentication" >> /home/$superUser/$clientDevice.ovpn
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

echo "Client Configuration Location: /home/$superUser/$clientDevice.ovpn"
echo "[+] Client Configuration Saved!"
