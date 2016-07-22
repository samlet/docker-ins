#!/bin/bash
set -e
INSTANCE=cc-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-8123}
IMAGE=${IMAGE:-"nile/cc-dev"}
APP_NAME=${APP_NAME:-"app"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/$APP_NAME \
	-v $HOME/caches/include:/usr/local/include \
	-e LD_LIBRARY_PATH=/usr/local/lib \
	-p $PORT:8123 \
	-v $HOME/caches/dev:/root \
	-w /$APP_NAME \
	$IMAGE $MICROS

# then run instructions in project folder:
# MICROS="bin/eg_hello_world" cc-runner.sh cc1
# MICROS="bin/eg_hello_world" PORT=9090 cc-runner.sh cc2

