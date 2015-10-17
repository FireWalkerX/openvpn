#!/bin/bash
# Setup unbound as recursive DNS server
# Written by JonathanW

# Install Unbound
echo "[-] Installing and Configuring Unbound"
echo "Installing unbound..."
yum install -y unbound > /dev/null 2>&1

# Grab Configuration File
echo "Retrieving and setting configuration file..."
> /etc/unbound/unbound.conf
cp ../resources/unbound.conf /etc/unbound/unbound.conf
unbound-control-setup  > /dev/null 2>&1
chown unbound:root /etc/unbound/unbound_*
chmod 440 /etc/unbound/unbound_*

# Retrieve primary root DNS servers for root hint validation
echo "Retrieving root hints for validation..."
wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/named.cache  > /dev/null 2>&1
unbound-anchor -r /etc/unbound/named.cache  > /dev/null 2>&1

echo "Restarting and Enabling Unbound service..."
systemctl restart unbound.service  > /dev/null 2>&1
sudo systemctl enable unbound.service  > /dev/null 2>&1

echo "Configuring cronjobs..."
crontab -l > /tmp/cronjob
echo "00 00 * * * unbound-control dump_cache > /tmp/DNS_cache.txt" >> /tmp/cronjob
crontab /tmp/cronjob
rm -f /tmp/cronjob
echo "[+] Installation of Unbound Complete!"
