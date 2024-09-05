#!/bin/bash

# Default values
FRAMERATE=120
BITRATE=6000000

gst-launch-1.0 -e \
        videotestsrc ! \
		video/x-raw,width=4000,height=3000,framerate=$FRAMERATE/1 ! \
		videoscale ! \
		videorate ! \
		videoconvert ! \
		timeoverlay ! \
		vp8enc target-bitrate=$BITRATE error-resilient=1 ! \
		matroskamux ! \
		filesink location="raw.mkv"
