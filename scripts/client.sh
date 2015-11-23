#!/bin/bash
# Writen by Johnny
# Setup client certificates for OpenVPN

#Get variables
source vars.conf

#Create temporary files
touch fileLocations
touch encFileLocations

echo "Note: You will be prompted for a password to encrypt individual configuration files. Unencrypted files will remain."
echo -n "Number of clients: " 
read repeat
for i in $(seq 1 $repeat);do
	#Get the client file name
	echo -n "Name of device/file: "
	read clientDevice

	#Generate client keys and certificates
	cd /etc/openvpn/easy-rsa
	source ./vars > /dev/null 2>&1
	./build-key --batch $clientDevice  > /dev/null 2>&1

	#Create Client Certificates
	echo "client" > /home/$superUser/$clientDevice.ovpn
	echo "dev tun" >> /home/$superUser/$clientDevice.ovpn
	echo "proto udp" >> /home/$superUser/$clientDevice.ovpn
	echo "remote $ip $port" >> /home/$superUser/$clientDevice.ovpn
	echo "dhcp-option DNS 10.8.0.1" >> /home/$superUser/$clientDevice.ovpn
	echo "resolv-retry infinite" >> /home/$superUser/$clientDevice.ovpn
	echo "nobind" >> /home/$superUser/$clientDevice.ovpn
	echo "persist-key" >> /home/$superUser/$clientDevice.ovpn
	echo "persist-tun" >> /home/$superUser/$clientDevice.ovpn
	echo "comp-lzo" >> /home/$superUser/$clientDevice.ovpn
	echo "verb 3" >> /home/$superUser/$clientDevice.ovpn
	echo "tls-version-min 1.2" >> /home/$superUser/$clientDevice.ovpn
	echo "script-security 1" >> /home/$superUser/$clientDevice.ovpn
	echo "cipher AES-256-CBC" >> /home/$superUser/$clientDevice.ovpn
	echo "auth SHA512" >> /home/$superUser/$clientDevice.ovpn
	echo "remote-cert-eku \"TLS Web Server Authentication\"" >> /home/$superUser/$clientDevice.ovpn
	echo "verify-x509-name 'C=$country, ST=$province, L=$city, O=$organization, OU=$organizationUnit, CN=$commonName, name=$commonName, emailAddress=$email'" >> /home/$superUser/$clientDevice.ovpn
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

	gpg -c /home/$superUser/$clientDevice.ovpn
	echo "Client Configuration Location: /home/$superUser/$clientDevice.ovpn" >> fileLocations
	echo "Encrypted Client Configuration Location: /home/$superUser/$clientDevice.ovpn.gpg" >> encFileLocations
	clear
	echo "Created configuration file $clientDevice"
done

echo "Unencrypted configurations:"
cat fileLocations
echo
echo "Encrypted configurations:"
cat encFileLocations
rm -f fileLocations
rm -f encFileLocations

#Fix permissions
chown -R $superUser:$superUser /home/$superUser
