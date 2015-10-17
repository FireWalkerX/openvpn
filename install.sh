#!/bin/bash
# Configure openvpn script

chmod +x scripts/*
./scripts/secure.sh
./scripts/openvpn.sh
./scripts/unbound.sh
./scripts/adblocker.sh
./scripts/client.sh

systemctl -f enable unbound.service
systemctl -f enable openvpn@server.service
systemctl restart openvpn@server.service
systemctl restart unbound
