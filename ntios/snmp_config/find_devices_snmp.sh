#!/bin/bash

#parameter 1 ip start address to scan
#parameter 2 ip end address to scan
#parameter 3 oid to scan

if [ -z "$1" ]
then
    start_ip="192.168.1.1"
else
    start_ip=$1
fi

if [ -z "$2" ]
then
    end_ip="192.168.1.255"
else
    end_ip=$2
fi

if [ -z "$3" ]
then
    #oid="1.3.6.1.4.1.20738"
    oid="1.3.6.1.2.1.1.1" 
else
    oid=$3
fi

#get the directory of this script 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
devices_ip=$DIR/../../.vscode/devices.txt

# Remove any existing devices.txt file
echo "" > $devices_ip

# Create a function to call the 'walk' executable with a given IP address
function scan_ip() {
    ip=$1
    ./walk $ip $oid > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo $ip >> $devices_ip
    fi
}

# Iterate over the IP range and call the 'scan_ip' function in parallel
#get  first three segments of ip 
network_id=$(echo $start_ip | cut -d '.' -f 1-3)

for i in $(seq -f "$network_id.%g" 1 255); do
    scan_ip $i &
    if (( $(jobs | wc -l) >= 4 )); then
        wait -n
    fi
done

# Wait for any remaining jobs to complete
wait

