#!/bin/bash

# Default values
HOST="192.168.1.13"
PORT=5004
MTU=1500

# Function to display usage information
usage() {
  echo "Usage: $0 [--host host] [--port port] [--mtu mtu]" 1>&2
  echo "Options:" 1>&2
  echo "  --host host          Hostname or IP address (default: $HOST)" 1>&2
  echo "  --port port          Port number (default: $PORT)" 1>&2
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
echo "Port: $PORT"
echo "MTUARG: $MTUARG"

gst-launch-1.0 \
	filesrc location=raw.mkv ! \
		matroskademux ! \
		rtpvp8pay mtu=$MTUARG ! \
                udpsink host=$HOST port=$PORT
