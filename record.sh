#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <pid>" >&2
  exit 1
fi

# -g 안하면 flamegraph 안된다
sudo perf record -g --call-graph=dwarf -F 99 -a -p $1 sleep 10
