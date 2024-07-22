#!/bin/bash

gst-launch-1.0 \
	filesrc location=sample.mp3 ! \
		decodebin ! audioconvert ! audioresample ! \
                opusenc bitrate=200000 ! \
                rtpopuspay ! \
                udpsink host=172.20.0.2 port=5002 \
