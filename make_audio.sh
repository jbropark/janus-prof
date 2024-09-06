#!/bin/bash

MYDIR=$(dirname $(realpath $0))

CHANNELS=1
RATE=16000
BITRATE=200000
FILENAME="raw.ogg"

DIR="/mnt/my"
FILEPATH="$DIR/$FILENAME"

docker run -v $MYDIR:$DIR \
	--rm \
	restreamio/gstreamer:2024-07-19T10-11-18Z-prod \
	gst-launch-1.0 \
		audiotestsrc ! \
			audioresample ! \
			audio/x-raw,channels=$CHANNELS,rate=$RATE ! \
			opusenc bitrate=$BITRATE ! \
			oggmux ! \
			filesink location=$FILEPATH
