#!/bin/bash
# Setup unbound as recursive DNS server
# Written by Johnny

# Install Unbound
yum install -y unbound > /dev/null 2>&1

# Grab Configuration File
> /etc/unbound/unbound.conf
cp resources/unbound.conf /etc/unbound/unbound.conf
unbound-control-setup  > /dev/null 2>&1
chown unbound:root /etc/unbound/unbound_*
chmod 440 /etc/unbound/unbound_*

# Retrieve primary root DNS servers for root hint validation
wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/named.cache  > /dev/null 2>&1
unbound-anchor -r /etc/unbound/named.cache  > /dev/null 2>&1

# Restart unbound and enable the service
systemctl restart unbound.service  > /dev/null 2>&1
sudo systemctl enable unbound.service  > /dev/null 2>&1

# Configure cron jobs to dump the cache every 24 hours
crontab -l > /tmp/cronjob
echo "00 00 * * * unbound-control dump_cache > /tmp/DNS_cache.txt" >> /tmp/cronjob
crontab /tmp/cronjob
rm -f /tmp/cronjob
