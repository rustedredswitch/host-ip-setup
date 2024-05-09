#!/bin/bash
HOST_PATH=$1
HOST_LABEL=$2
IP=$3
OLD_IP_LIN=$(grep -P "^.*$HOST_LABEL" $HOST_PATH | awk '{print $1}')
echo "Old $HOST_LABEL IP in WSL: $OLD_IP_LIN"
sed -i "s/$OLD_IP_LIN/$IP/g" $HOST_PATH
