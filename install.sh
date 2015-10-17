#!/bin/bash
# Configure openvpn script

chmod +x scripts/*
./scripts/secure.sh
./scripts/openvpn.sh
./scripts/unbound.sh
./scripts/adblocker.sh
./scripts/client.sh

# sudo systemctl enable unbound.service
systemctl restart openvpn@server.service
