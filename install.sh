#!/bin/bash
# Configure openvpn script

mkdir install
cd install
wget https://raw.githubusercontent.com/jonathanwalker/openvpn/master/unbound.sh > /dev/null 2>&1
wget https://raw.githubusercontent.com/jonathanwalker/openvpn/master/adblocker.sh > /dev/null 2>&1
wget https://raw.githubusercontent.com/jonathanwalker/openvpn/master/setup.sh > /dev/null 2>&1
sh unbound.sh
sh adblocker.sh
cd ..
rm -rf install
