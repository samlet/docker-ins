#!/bin/bash
set -e
INSTANCE=elixir-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-4000}
IMAGE=${IMAGE:-"nile/elixir:1.2"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/app \
	-p $PORT:4000 \
	-v $HOME/caches/dev:/root \
	-w /app \
	$IMAGE $MICROS

# then run instructions in source folder:
# MICROS="mix phoenix.server" elixir-runner.sh e1
# MICROS="mix phoenix.server" PORT=9090 elixir-runner.sh e2

