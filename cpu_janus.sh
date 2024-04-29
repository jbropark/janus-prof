#!/bin/bash
PIDS=`pgrep "^janus$"`
COUNT=$(echo "$PIDS" | wc -l)

if [ $COUNT -ne 1 ]; then
  echo "Warning: Duplicated PIDS" >&2
  echo "$PIDS" >&2
  echo "Do not record. Terminate." >&2
  exit 1
fi

pidstat -p $PIDS 1 1
