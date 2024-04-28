#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <filename>"
fi

sudo perf script -f | fg/stackcollapse-perf.pl --all | fg/flamegraph.pl  --color=java > $1
