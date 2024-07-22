gst-launch-1.0 -e -v udpsrc port=5002 \
	! "application/x-rtp, media=(string)audio, channels=(int)1, encoding-name=(string)OPUS, clock-rate=(int)48000, payload=96" \
	! rtpopusdepay \
	! opusdec \
	! audioresample \
	! audioconvert \
	! vorbisenc \
	! webmmux \
	! filesink location="audio.webm"
