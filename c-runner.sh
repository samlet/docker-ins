#!/bin/bash
set -e
INSTANCE=c-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-8888}
IMAGE=${IMAGE:-"nile/c-dev"}
APP_NAME=${APP_NAME:-"app"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/$APP_NAME \
	-v $HOME/caches/include:/usr/local/include \
	-e LD_LIBRARY_PATH=/usr/local/lib \
	-p $PORT:8888 \
	-v $HOME/caches/dev:/root \
	-w /$APP_NAME \
	$IMAGE $MICROS

# then run instructions in source folder:
# APP_NAME="json_yajl" MICROS="kore run" c-runner.sh c1
# APP_NAME="json_yajl" MICROS="kore run" PORT=9090 c-runner.sh c2

