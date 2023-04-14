#!/bin/bash


#get current script directory 
PROJ_NAME="ntios_app"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXEC_PATH="$DIR/run.sh"

# Check if the unit file already exists
if [ -f /etc/systemd/system/$PROJ_NAME.service ]; then
  # Stop the service and update the unit file
  systemctl stop $PROJ_NAME.service
fi

#Update the unit file
echo "[Unit]
Description=ntios application
After=multi-user.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=$USER
ExecStart=$EXEC_PATH

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$PROJ_NAME.service

# Reload systemd daemon to reflect changes
systemctl daemon-reload

# Start the service
systemctl start $PROJ_NAME.service
