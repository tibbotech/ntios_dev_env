#!/bin/bash

# Define the Sunplus OUIs
OUI1="00:11:05"
OUI2="1c:50:1e"
OUI3="fc:4b:bc"

#if parameter 1 is empty then set scanip to 192.168.1.100
#get the ip address of gateway 
#convert gateway ip to 192.168.XX.XX/24 
if [ -z "$1" ]; then
    scan_ip=$(ip route | grep default | awk '{print $3}')
    scan_ip=$(echo $scan_ip | cut -d "." -f 1-3).0/24
else
    scan_ip=$1
fi
echo "Scanning this range: $scan_ip" 
#get this files location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# Perform a quick ping sweep of the network with fping
fping -a -g $scan_ip -t 1 -q > ../.vscode/hosts.txt


#clear ../.vscode/devices.txt
echo "" > ../.vscode/devices.txt

# Filter the results for devices with Sunplus OUIs
while read -r host; do
  if [[ $(arp "$host" | grep -c "$OUI1\|$OUI2\|$OUI3") -ne 0 ]]; then
    #append each host to the devices file
    echo "$host" >> ../.vscode/devices.txt
  fi
done < ../.vscode/hosts.txt

# Remove the temporary file
rm ../.vscode/hosts.txt