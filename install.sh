#!/bin/bash
# Configure openvpn script
# Writen by Johnny

echo "Please be patient while openvpn, unbound, and configurations are setup..."

# Set executable permissions and run scripts
chmod +x scripts/*
./scripts/secure.sh
./scripts/openvpn.sh
./scripts/unbound.sh
./scripts/adblocker.sh
./scripts/client.sh

# Enable and start services
systemctl -f enable unbound.service
systemctl -f enable openvpn@server.service
systemctl start openvpn@server.service
systemctl start unbound

# Clear vars.conf file
> vars.conf
