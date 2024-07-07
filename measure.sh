#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "usage: $0 <dir>"
  exit 1
fi

DIR="$1"

echo "create directory '$DIR'"
mkdir $DIR || exit 1

for i in {1..10}
do
docker stats --format json --no-stream > "$DIR/dstat-$i.txt"
sleep 0.1
vnstat -tr 5 -i janus --json > "$DIR/vnstat-$i.txt"
sleep 0.1
vmstat 1 10 > "$DIR/vmstat-$i.txt"
sleep 0.1
done

echo "success to save measures to '$DIR'"

cat $DIR/*-1.txt
printf '\7'
