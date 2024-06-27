#!/bin/bash

# Default values
HOST="172.20.0.2"
PORT=5002

# Function to display usage information
usage() {
  echo "Usage: $0 [-h host] [-p port]" 1>&2
  echo "Options:" 1>&2
  echo "  -h host    Hostname or IP address (default: 127.0.0.1)" 1>&2
  echo "  -p port    Port number (default: 5002)" 1>&2
  exit 1
}

# Parse arguments
while getopts ":h:p:" opt; do
  case ${opt} in
    h )
      HOST=$OPTARG
      ;;
    p )
      PORT=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Usage if no arguments provided
if [ $# -gt 0 ]; then
  echo "Unexpected argument: $1" 1>&2
  usage
fi

APORT=$PORT
VPORT=$((PORT + 2))
echo "Host: $HOST"
echo "Audio Port: $APORT"
echo "Video Port: $VPORT"


gst-launch-1.0 \
        audiotestsrc ! \
                audioresample ! audio/x-raw,channels=1,rate=16000 ! opusenc bitrate=200000 ! \
                        rtpopuspay ! udpsink host=$HOST port=$APORT \
        videotestsrc ! video/x-raw,width=640,height=480 ! \
	            videoscale ! videorate ! videoconvert ! timeoverlay ! vp8enc target-bitrate=4000000 error-resilient=1 ! \
                        rtpvp8pay ! udpsink host=$HOST port=$VPORT
