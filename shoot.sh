#!/bin/bash

# Default values
HOST="192.168.1.13"
PORT=5002
MTU=1500
VIDEO="raw.mkv"
AUDIO="raw.ogg"

# Function to display usage information
usage() {
  echo "Usage: $0 [--host host] [--port port] [--mtu mtu] [--audio audio] [--video video]" 1>&2
  echo "Options:" 1>&2
  echo "  --host   host          Hostname or IP address (default: $HOST)" 1>&2
  echo "  --port   port          Port number (default: $PORT)" 1>&2
  echo "  --mtu    mtu           MTU (default: $MTU)" 1>&2
  echo "  --audio  audio         Audio Path (default: $AUDIO)" 1>&2
  echo "  --video  video         Video Path (default: $VIDEO)" 1>&2
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
    --mtu)
      MTU=$2
      shift 2
      ;;
    --audio)
      AUDIO=$2
      shift 2
      ;;
    --video)
      VIDEO=$2
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

if ! [ -f $AUDIO ]; then
  echo "File not exist: $AUDIO" 1>&2
  exit 1
fi

if ! [ -f $VIDEO ]; then
  echo "File not exist: $VIDEO" 1>&2
  exit 1
fi

APORT=$PORT
VPORT=$((PORT + 2))
MTUARG=$((MTU - 100))
echo "Host: $HOST"
echo "Audio Port: $APORT"
echo "Video Port: $VPORT"
echo "MTUARG: $MTUARG"

MYDIR=$(dirname $(realpath $0))
DIR="/mnt/my"
AUDIO="$DIR/$AUDIO"
VIDEO="$DIR/$VIDEO"

docker run -v $MYDIR:$DIR \
	--rm \
	restreamio/gstreamer:2024-07-19T10-11-18Z-prod \
	gst-launch-1.0 \
		multifilesrc location=$AUDIO loop=true ! \
			oggdemux ! \
			rtpopuspay mtu=$MTUARG ! \
			udpsink host=$HOST port=$APORT \
		filesrc location=$VIDEO ! \
			matroskademux ! \
			rtpvp8pay mtu=$MTUARG ! \
			udpsink host=$HOST port=$VPORT
