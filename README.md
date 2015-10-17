#OpenVPN Installation and Configuration

This script allows you to install and configure OpenVPN on Centos 7. This was created for a server on DigitalOcean but should work on any Centos server. 

##Installation

The installation was created to be incredibly simple, with very basic linux knowledge required. 

Tip: Instead of going through this manually, just run this command

```wget https://github.com/jonathanwalker/openvpn/archive/master.zip; yum install -y unzip > /dev/null 2>&1; unzip master.zip; cd openvpn-master; chmod +x install.sh; nano vars.conf; clear; ./install.sh```

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

```./install.sh```
