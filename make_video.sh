#!/bin/bash

MYDIR=$(dirname $(realpath $0))

# Default values
FRAMERATE=80
BITRATE=6000000
FILENAME="raw.mkv"

DIR="/mnt/my"
FILEPATH="$DIR/$FILENAME"

docker run -v $MYDIR:$DIR \
        --rm \
        restreamio/gstreamer:2024-07-19T10-11-18Z-prod \
        gst-launch-1.0 -e \
		videotestsrc ! \
			video/x-raw,width=400,height=300,framerate=$FRAMERATE/1 ! \
			videoscale ! \
			videorate ! \
			videoconvert ! \
			timeoverlay ! \
			vp8enc target-bitrate=$BITRATE error-resilient=1 ! \
			matroskamux ! \
			filesink location=$FILEPATH
