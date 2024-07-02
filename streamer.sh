#!/bin/bash

# Default values
HOST="172.20.0.2"
PORT=5002
SIZE=1
MTU=1500

# Function to display usage information
usage() {
  echo "Usage: $0 [--host host] [--port port] [--size size] [--mtu mtu]" 1>&2
  echo "Options:" 1>&2
  echo "  --host host    Hostname or IP address (default: $HOST)" 1>&2
  echo "  --port port    Port number (default: $PORT)" 1>&2
  echo "  --size size    Size of image (default: $SIZE)" 1>&2
  echo "  --mtu  mtu     MTU (default: $MTU)" 1>&2
  exit 1
}

# Parse arguments
while [ $# -gt 0 ]; do
  case $1 in
    --host)
      HOST="$2"
      shift 2
      ;;
    --port)
      PORT=$2
      shift 2
      ;;
    --size)
      SIZE=$2
      shift 2
      ;;
    --mtu)
      MTU=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

WIDTH=$((320 * $SIZE))
HEIGHT=$((240 * $SIZE))
BITRATE=$((1000000 * $SIZE * $SIZE))
APORT=$PORT
VPORT=$((PORT + 2))
MTUARG=$((MTU - 100))
echo "Host: $HOST"
echo "Audio Port: $APORT"
echo "Video Port: $VPORT"
echo "Size: $SIZE"
echo "Width: $WIDTH"
echo "Height: $HEIGHT"
echo "BR: $BITRATE"
echo "MTUARG: $MTUARG"

gst-launch-1.0 \
        audiotestsrc ! \
                audioresample ! \
		audio/x-raw,channels=1,rate=16000 ! \
		opusenc bitrate=200000 ! \
                rtpopuspay ! \
		udpsink host=$HOST port=$APORT \
        videotestsrc ! \
		video/x-raw,width=$WIDTH,height=$HEIGHT ! \
		queue ! videoscale ! \
		queue ! videorate ! \
		queue ! videoconvert ! \
		queue ! timeoverlay ! \
		queue ! vp8enc target-bitrate=$BITRATE error-resilient=1 ! \
		rtpvp8pay mtu=$MTUARG ! udpsink host=$HOST port=$VPORT
