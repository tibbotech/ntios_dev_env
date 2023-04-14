#!/bin/bash

#get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

target_device_file=$DIR/target.device
launch_json_file=$DIR/launch.json


#check argument 1 if it's present set default_ip to it and write it to target.device
if [ -n "$1" ]; then
    default_ip=$1
    echo $default_ip > $target_device_file
else
    default_ip="192.168.1.100"
fi



# Check if target.device file exists and read the IP address from it
if [ -f "$target_device_file" ]; then
    ip_address=$(cat $target_device_file)
else
    ip_address=$default_ip
fi

#create configuration 
ltpp3g2_launch_config=$(cat << EOF
{
            "name": "Attach to LTPP3G2",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/build/ntios_dev_env",
            "miDebuggerServerAddress": "$ip_address:3333",
            "MIMode": "gdb",
            "cwd": "\${workspaceFolder}",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Load gdbinit",
                    "text": "-interpreter-exec console \"source -v \${workspaceRoot}/.vscode/.gdbinit\""
                }
            ],
            "miDebuggerPath": "/usr/bin/gdb-multiarch",
            "targetArchitecture": "arm",
            "preLaunchTask": "LTPP3G2: Build and Debug"
}
EOF
)

# Check if launch.json file exists
if [ ! -f "$launch_json_file" ]; then
    # If launch.json does not exist, create it with the new configuration
    launch_json_content=$(cat << EOF
{
    "version": "0.2.0",
    "configurations": [
        $ltpp3g2_launch_config
    ]
}
EOF
)
    echo "$launch_json_content" > $launch_json_file
else
    # If launch.json already exists clear comments
    sed -i 's/^\s*\/\*.*\*\/\s*/ /g' $launch_json_file
    sed -i '/^\s*\/\//d' $launch_json_file
    #check if configurations array is empty
    if [ "$(jq '.configurations | length' $launch_json_file)" -eq "0" ]; then
        # If configurations array is empty, add the new configuration to it
        jq --argjson ltpp3g2_launch_config "$ltpp3g2_launch_config" '.configurations |= [$ltpp3g2_launch_config]' $launch_json_file > $launch_json_file.tmp && mv $launch_json_file.tmp $launch_json_file
    else
        # If configurations array is not empty, use JQ to replace the configuration named "Attach to LTPP3G2" with the new configuration
         jq --argjson ltpp3g2_launch_config "$ltpp3g2_launch_config" '.configurations |= map(if .name == "Attach to LTPP3G2" then $ltpp3g2_launch_config else . end)' $launch_json_file > $launch_json_file.tmp && mv $launch_json_file.tmp $launch_json_file
    fi
fi