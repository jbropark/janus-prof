#!/bin/bash

# Default values
HOST="172.20.0.2"
PORT=5002
FRAMERATE=30
BITRATE=1000000
MTU=1500

# Function to display usage information
usage() {
  echo "Usage: $0 [--host host] [--port port] [--size size] [--mtu mtu]" 1>&2
  echo "Options:" 1>&2
  echo "  --host host          Hostname or IP address (default: $HOST)" 1>&2
  echo "  --port port          Port number (default: $PORT)" 1>&2
  echo "  --frame framerate    Framerate of testsrc (default: $FRAMERATE)" 1>&2
  echo "  --bit bitrate        Bitrate of video encoding (default: $BITRATE)" 1>&2
  echo "  --mtu  mtu           MTU (default: $MTU)" 1>&2
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
    --bit)
      BITRATE=$2
      shift 2
      ;;
    --frame)
      FRAMERATE=$2
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

APORT=$PORT
VPORT=$((PORT + 2))
MTUARG=$((MTU - 100))
echo "Host: $HOST"
echo "Audio Port: $APORT"
echo "Video Port: $VPORT"
echo "BitRate: $BITRATE"
echo "FrameRate: $FRAMERATE"
echo "MTUARG: $MTUARG"

gst-launch-1.0 \
        audiotestsrc ! \
                audioresample ! \
		audio/x-raw,channels=1,rate=16000 ! \
		opusenc bitrate=200000 ! \
                rtpopuspay ! \
		udpsink host=$HOST port=$APORT \
        videotestsrc ! \
		video/x-raw,width=400,height=300,framerate=$FRAMERATE/1 ! \
		videoscale ! \
		videorate ! \
		videoconvert ! \
		timeoverlay ! \
		vp8enc target-bitrate=$BITRATE error-resilient=1 ! \
		rtpvp8pay mtu=$MTUARG ! udpsink host=$HOST port=$VPORT
