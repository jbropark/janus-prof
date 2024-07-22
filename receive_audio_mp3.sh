gst-launch-1.0 -e -v udpsrc port=5002 \
	! "application/x-rtp, media=(string)audio, channels=(int)1, encoding-name=(string)OPUS, clock-rate=(int)48000" \
	! rtpopusdepay \
	! opusdec \
	! audioconvert \
	! lamemp3enc bitrate=192 \
	! filesink location="audio.mp3"
