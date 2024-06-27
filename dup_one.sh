#!/bin/bash

interval="10"
after="0.1"
host="172.20.0.2"
port="8188"
n="5"
repeat="30"

# getopts를 통해 명령줄 인수 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --interval)
            interval="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        -n)
            n="$2"
            shift 2
            ;;
        --repeat)
            repeat="$2"
            shift 2
            ;;
	--after)
	    after="$2"
	    shift 2
	    ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 결과 출력
echo "Interval: $interval"
echo "After: $after"
echo "Host: $host"
echo "Port: $port"
echo "N: $n"
echo "Repeat: $repeat"

for ((i = 1; i <= $repeat; i++)); do
  echo "run iter $i"
  ./client.sh start -h $host -p $port -n $n
  sleep $interval
  ./client.sh stop
  sleep $after
done
