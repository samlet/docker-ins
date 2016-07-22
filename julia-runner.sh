#!/bin/bash
set -e
INSTANCE=julia-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"julia"}
PORT=${PORT:-8080}
IMAGE=${IMAGE:-"nile/julia:0.4.5"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/app \
	-p $PORT:$PORT \
	-v $HOME/caches/julia.root:/root \
	-w /app \
	$IMAGE $MICROS

# then run instructions in source folder:
# MICROS="julia Main.jl" julia-runner.sh ju1
# MICROS="julia Main.jl" PORT=9090 julia-runner.sh ju2

