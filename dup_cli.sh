#!/bin/bash

./client.sh start -u ws://172.20.0.2:8188/janus -n 1
./client.sh start -u ws://172.20.0.3:8188/janus -n 2
./client.sh start -u ws://172.20.0.4:8188/janus -n 3

sleep 10
./client.sh stop
