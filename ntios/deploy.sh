#!/bin/bash

echo "Deploying to target device..."
# Define the target device's IP address and username
TARGET_IP=$1
TARGET_USER=$2
PASSWORD=$3

# Define the name of the local folder and the remote folder
LOCAL_FOLDER="/root/ntios/build_output/ltpp3g2"
REMOTE_FOLDER="/home/ubuntu/"

# Use expect to automate the SFTP process
expect -c "
  spawn sftp $TARGET_USER@$TARGET_IP
  expect \"password:\"
  send \"$PASSWORD\n\"
  expect \"sftp>\"
  send \"put -r $LOCAL_FOLDER $REMOTE_FOLDER\n\"
  expect \"sftp>\"
  send \"exit\n\"
"