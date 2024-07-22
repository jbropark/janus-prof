#/bin/bash

usage() {
  echo "Usage: $0 [-i image] <subcommand>" 1>&2
  echo "       subcommand: start | stop" 1>&2
  echo "Options:" 1>&2
  echo "  -i image   Image name (default: )" 1>&2
  exit 1
}

# Function to display start subcommand usage
usage_start() {
  echo "Usage: $0 [-i image] start [-n num] [-u url]" 1>&2
  echo "Options:" 1>&2
  echo "  -i image   Image name (default: )" 1>&2
  echo "  -n num     Number to create" 1>&2
  echo "  -c client  Number of client" 1>&2
  echo "  -u url     URL for janus-gateway" 1>&2
  echo "  -p port    PORT for janus-gateway (if url not given)" 1>&2
  echo "  -h host    URL for janus-gateway (if url not given)" 1>&2
  exit 1
}

# Function to display stop subcommand usage
usage_stop() {
  echo "Usage: $0 stop [-i image]" 1>&2
  echo "Options:" 1>&2
  echo "  -i image   Image name" 1>&2
  exit 1
}

IMAGE="wrtt/ubuntu-20.04_x86_64:fpga-230710"
# Parse main arguments
while getopts ":i:" opt; do
  case ${opt} in
    i )
      IMAGE=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Parse subcommand
subcommand=$1
shift

NUM=1
CLIENT=200
URL=""
HOST="172.20.0.2"
PORT="8188"

case "$subcommand" in
  start)
    # Parse arguments for 'start' subcommand
    parse_start_args() {
      while getopts ":n:u:h:p:c:" opt; do
        case ${opt} in
          n )
            NUM=$OPTARG
            ;;
	  u )
	    URL=$OPTARG
	    ;;
	  p )
	    PORT=$OPTARG
	    ;;
	  h )
	    HOST=$OPTARG
	    ;;
	  c )
            CLIENT=$OPTARG
	    ;;
          \? )
            echo "Invalid option: $OPTARG" 1>&2
            usage_start
            ;;
          : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            usage_start
            ;;
        esac
      done
      shift $((OPTIND -1))

      if [ -z "$URL" ]; then
        URL="ws://$HOST:$PORT/janus"
      fi
      
      # Usage if required arguments are not provided
      if [ -z "$IMAGE" ] || [ -z "$NUM" ] || [ -z "$URL" ]; then
        echo "Required argument(s) missing" 1>&2
        usage_start
      fi
    }
    
    parse_start_args "$@"
    # start subcommand


    echo "URL: $URL"
    echo "Num  : $NUM"
    echo "Client : $CLIENT"
    echo "Image: $IMAGE"

    COUNT=1
    while [ $COUNT -le $NUM ]; do
        docker run \
		--rm -d --network host --name wrtt-client-$COUNT \
		--entrypoint /home/workspace/webrtc-testing-tool-ubuntu-20.04_x86_64/bin/wrtt \
		$IMAGE \
		--log-level=4 --signaling-urls=$URL \
		--insecure=false --the-number-of-client=$CLIENT \
		--openh264-path=/home/workspace/webrtc-testing-tool-ubuntu-20.04_x86_64/openh264/lib/libopenh264-2.1.1-linux64.6.so \
		--hatch-rate=500 --client-role=streaming janus --room-id=1
        COUNT=$((COUNT + 1))
done

    ;;
  stop)
    # Usage if required arguments are not provided
    if [ -z "$IMAGE" ]; then
      echo "Required argument(s) missing" 1>&2
      usage_stop
    fi
    
    # stop subcommand
    CONTAINERS=`docker ps -aq --filter ancestor=$IMAGE`
    if [ -z "$CONTAINERS" ]; then
	echo "Error: No containers found for image: $IMAGE"
	exit 1
    fi

    echo "Start stop containers"
    docker stop $CONTAINERS
    echo "Finish stop containers"
    ;;
  *)
    echo "Invalid subcommand: $subcommand" 1>&2
    echo "Subcommands: start | stop" 1>&2
    exit 1
    ;;
esac
