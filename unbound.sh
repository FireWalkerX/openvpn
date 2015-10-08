#!/bin/bash
# Setup unbound as recursive DNS server
# Written by JonathanW

# Install Unbound
echo "Installing unbound..."
yum install -y unbound > /dev/null 2>&1

# Grab Configuration File
echo "Retrieving configuration file..."
> /etc/unbound/unbound.conf
curl --silent https://raw.githubusercontent.com/jonathanwalker/openvpn/master/files/unbound.conf > /etc/unbound/unbound.conf
unbound-control-setup  > /dev/null 2>&1
chown unbound:root /etc/unbound/unbound_*
chmod 440 /etc/unbound/unbound_*

# Retrieve primary root DNS servers for root hint validation
echo "Retrieving root hints for validation..."
wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/named.cache  > /dev/null 2>&1
unbound-anchor -r /etc/unbound/named.cache  > /dev/null 2>&1

echo "Restarting unbound service..."
systemctl restart unbound.service  > /dev/null 2>&1
