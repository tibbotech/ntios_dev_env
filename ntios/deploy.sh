#!/bin/bash

echo "Deploying to target device..."
# Define the target device's IP address and username
TARGET_IP=$1
TARGET_USER=$2
PASSWORD=$3

#get path to current script file 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#get the project name
cd $DIR/../
PROJ_NAME=$(basename $(pwd))
cd $DIR

#if exists delete the build folder
if [ -d "$DIR/../build/ntios" ]; then
    rm -rf $DIR/../build/ntios
fi

#copy the files to the deployment folder
cp -r $DIR/../ntios $DIR/../build/
cp $DIR/../build/$PROJ_NAME $DIR/../build/ntios
echo "./$PROJ_NAME" >>  $DIR/../build/ntios/run.sh

# Define the name of the local folder and the remote folder
LOCAL_FOLDER=$DIR/../build/ntios
REMOTE_FOLDER="/home/ubuntu/ntios"

expect <<EOF
  spawn ssh $TARGET_USER@$TARGET_IP
  expect "password:"
  send "$PASSWORD\n"
  expect "ubuntu@"
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
  expect "ubuntu@"
  send "cd $REMOTE_FOLDER\r"
  send "echo $PASSWORD | sudo -S ./run.sh\r"
  set timeout 1000000
  expect "ubuntu@"
  send "exit\r"
  expect eof
EOF


wait