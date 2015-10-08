#!/bin/bash
# Block advertisements
# Written by Johnny

# IP address to send traffic
blackHoleDNS="127.0.0.1"
blackHoleDNS6="::1"

# Location of configuration file
configurationFile="/etc/unbound/local.d/adaway.conf"
rm -f $configurationFile

# Retrieve windows ad list and convert dos2unix
curl -s http://winhelp2002.mvps.org/hosts.txt > /tmp/winhelp2002
curl -s http://hosts-file.net/ad_servers.txt > /tmp/hosts-file
curl -s https://adaway.org/hosts.txt > /tmp/adaway
dos2unix /tmp/winhelp2002  > /dev/null 2>&1
dos2unix /tmp/hosts-file  > /dev/null 2>&1
dos2unix /tmp/adaway  > /dev/null 2>&1

# Get yoyo advertisement list
curl -s -d mimetype=plaintext -d hostformat=unixhosts http://pgl.yoyo.org/adservers/serverlist.php? | sort > /tmp/blackholeHosts

# Get winhelp2002 advertisement list
curl -s /tmp/winhelp2002 | grep -v "#" | grep -v "127.0.0.1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | sort >> /tmp/blackholeHosts

# Get host-file advertisement list
curl -s /tmp/hosts-file | grep -v "#" | grep -v "::1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> /tmp/blackholeHosts

# Get someonewhocares advertisement/malware/spam list
curl -s http://someonewhocares.org/hosts/hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | grep -v '^\\' | grep -v '\\$' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> /tmp/blackholeHosts

# Get adaway advertisement list
curl -s /tmp/adaway | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | grep -v '^\\' | grep -v '\\$' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> /tmp/blackholeHosts

# Trim and format domains for unbound 
cat /tmp/blackholeHosts | sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' > /tmp/blackholeDomains
for a in `cat /tmp/blackholeDomains`; do
                echo 'local-data: "'$a' A '$blackHoleDNS'"' >> $configurationFile
done

# Remove temporary files
rm -f /tmp/blackholeHosts
rm -f /tmp/blackholeDomains
rm -f /tmp/winhelp2002
rm -f /tmp/hosts-file
rm -f /tmp/adaway

systemctl restart unbound.service > /dev/null 2>&1

echo "Setup complete!"
