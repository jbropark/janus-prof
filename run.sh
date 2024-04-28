#!/bin/bash

echo "Clear before start"

./client.sh stop

for ((i = 1; i <= 30; i++))
do
	echo "Run for $i"
	./client.sh start -n $i
	sleep 20  # todo: measure
	./record_janus.sh
	sleep 1
	./plot.sh "debug-$i.svg"

done
