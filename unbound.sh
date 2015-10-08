#!/bin/bash
# Setup unbound as recursive DNS server
# Written by JonathanW

# Install Unbound
echo "Installing unbound..."
yum install unbound > /dev/null 2>&1
# Life without dig is hard
echo "Installing dig..."
yum install bind-utils  > /dev/null 2>&1

# Grab Configuration File
echo "Retrieving configuration file..."
curl https://raw.githubusercontent.com/jonathanwalker/openvpn/master/files/unbound.conf > /etc/unbound/unbound.conf
unbound-control-setup
chown unbound:root /etc/unbound/unbound_*
chmod 440 /etc/unbound/unbound_*

# Retrieve primary root DNS servers for root hint validation
echo "Retrieving root hints for validation..."
wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/named.cache
unbound-anchor -r /etc/unbound/named.cache

echo "Restarting unbound service..."
systemctl status unbound.service
