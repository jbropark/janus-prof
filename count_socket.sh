sudo ls /proc/`pgrep janus`/fd -al | grep socket | wc -l
