#!/bin/bash

gst-launch-1.0 \
        audiotestsrc ! \
	        audioresample ! \
                audio/x-raw,channels=1,rate=16000 ! \
                opusenc bitrate=200000 ! \
		oggmux ! \
		filesink location="raw.ogg"
