#!/bin/bash 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NTIOS_LIB_PATH=$DIR/libs

LD_LIBRARY_PATH=$NTIOS_LIB_PATH:/usr/lib/arm-linux-gnueabihf/
export LD_LIBRARY_PATH 
