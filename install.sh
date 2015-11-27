#!/bin/bash
# Configure openvpn script
# Writen by Johnny

#Test if tun/tap is enabled
if test ! -e "/dev/net/tun"; then
        echo "TUN/TAP is not enabled. Please enable for this to work."
		exit
fi

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

# Echo final notes
echo "Note: SSH is now on port 222, root login is disabled, and user added to sudoers(add ssh keys)"
echo "Note: Download encrypted ovpn files and remove unencrypted files when no longer needed"
