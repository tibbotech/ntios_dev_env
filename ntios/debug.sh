#!/bin/bash

echo "Deploying to target device..."
# Define the target device's IP address and username
TARGET_IP=$1
TARGET_USER=$2
PASSWORD=$3

KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"

GDBPORT=3333

#get path to current script file 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#get the project name
cd $DIR/../
PROJ_NAME=$(basename $(pwd))
cd $DIR

#get the username from target.username
USERNAME=$(cat $DIR/../.vscode/target.username)

#if exists delete the build folder
if [ -d "$DIR/../build/ntios" ]; then
    rm -rf $DIR/../build/ntios
fi

#copy the files to the deployment folder
cp -r $DIR/../ntios $DIR/../build/
cp $DIR/../build/$PROJ_NAME $DIR/../build/ntios

echo "gdbserver 0.0.0.0:$GDBPORT ./$PROJ_NAME" >>   $DIR/../build/ntios/run.sh

# Define the name of the local folder and the remote folder
LOCAL_FOLDER=$DIR/../build/ntios
REMOTE_FOLDER="/home/$USERNAME/ntios"


# Check if the known_hosts file exists
if [ ! -f "$KNOWN_HOSTS_FILE" ]; then
    touch "$KNOWN_HOSTS_FILE"
fi

# Add the remote server's public key to known_hosts
# Use ssh-keyscan to get the public key for the target IP
REMOTE_SSH_KEYS=$(ssh-keyscan "$TARGET_IP" 2>/dev/null)

# Check if the key is already in the known_hosts file
if grep -q "$REMOTE_SSH_KEYS" "$KNOWN_HOSTS_FILE"; then
    echo "Key already exists in $KNOWN_HOSTS_FILE"
else
    # Add the key to the known_hosts file
    echo "Adding key to $KNOWN_HOSTS_FILE"
    echo "$REMOTE_SSH_KEYS" >> "$KNOWN_HOSTS_FILE"
fi

echo "Starting Debugging 1..."


expect <<EOF
  spawn ssh $TARGET_USER@$TARGET_IP
  expect "password:"
  send "$PASSWORD\n"
  expect "$USERNAME@"
  send "echo $PASSWORD | rm -rf $REMOTE_FOLDER\r"
  send "exit" 
  spawn sftp $TARGET_USER@$TARGET_IP
  expect "password:"
  send "$PASSWORD\n"
  expect "sftp>"
  send "put  -r $LOCAL_FOLDER $REMOTE_FOLDER\n"
  expect "sftp>"
  send "exit\n"
  spawn ssh $TARGET_USER@$TARGET_IP
  expect "password:"
  send "$PASSWORD\n"
  expect "$USERNAME@"
  send "cd $REMOTE_FOLDER\r"
  send "echo $PASSWORD | sudo -S systemctl stop ntios_app.service\r"
  send "echo $PASSWORD | sudo -S ufw allow $GDBPORT\r"
  puts "Starting Debugging 2..."
  send "echo $PASSWORD | sudo -S ./run.sh\r"
  set timeout 1000000
  expect "$USERNAME@"
  send "exit\r"
  expect eof
EOF

