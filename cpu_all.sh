#!/bin/bash
TOP=`top -bn1`
RES=`echo "$TOP" | grep -e janus -e wrtt -e gst`
HEAD=`echo "$TOP" | grep -e Cpu`
echo "$HEAD"
echo "$RES"

SUM=$(echo "$RES" | sed 's/\s\+/\t/g' | awk '{ sum += $9 } END { print sum }')
echo "%CPU: $SUM"
