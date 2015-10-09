#!/bin/bash

yum install -y perl > /dev/null 2>&1
wget http://www.configserver.com/free/csf.tgz
tar -xzf csf.tgz > /dev/null 2>&1
cd csf
bash install.sh > /dev/null 2>&1
perl /usr/local/csf/bin/csftest.pl
