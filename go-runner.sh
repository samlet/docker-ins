#!/bin/bash
set -e
INSTANCE=go-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-8080}
IMAGE=${IMAGE:-"nile/go-dev"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/go/src:/go/src \
	-v $HOME/works:/works \
	-v $HOME/caches/dev:/root \
	-v $(pwd):/app \
	-e GOPATH=/go \
	-p $PORT:8080 \
	-w /app \
	$IMAGE $MICROS

# then run instructions in source folder:
# MICROS="/app/whoami" go-runner.sh g1


