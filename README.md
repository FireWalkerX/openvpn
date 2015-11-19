#OpenVPN Installation and Configuration

This script allows you to install and configure OpenVPN on Centos 7. This script sets up openvpn configurations, unbound recursive dns setup, blocks advertisements/malware/tracking domains by DNS, and employs extremely hardened settings.

Security:

* Minimum TLS Version 1.2
* SHA512 HMAC Authentication
* TLS Authentication Secret
* Checks Extended Key Usage
* Verifies X.509 Subject Names
* 4096-bit RSA
* TLS ciphers TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256


##Installation

The installation was created to be incredibly simple, with very basic linux knowledge required. 

Tip: Instead of going through this manually, just run this command

```yum install -y unzip wget > /dev/null 2>&1; wget -q https://github.com/jonathanwalker/openvpn/archive/master.zip; unzip master.zip > /dev/null 2>&1; cd openvpn-master; chmod +x install.sh; nano vars.conf; clear; ./install.sh```

1, Download the master zip file

```wget https://github.com/jonathanwalker/openvpn/archive/master.zip```

2, Install unzip to extract the files

```yum install -y unzip```

3, Extract the zip file

```unzip master.zip```

4, Move to the directory

```cd openvpn-master```

5, Allow executable permissions for the installation script

```chmod +x install.sh```

6, Run the installation script

```sudo ./install.sh```
