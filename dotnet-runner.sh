#!/bin/bash
set -e
INSTANCE=dotnet-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-5000}
IMAGE=${IMAGE:-"microsoft/dotnet"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/app \
	-p $PORT:5000 \
	-v $HOME/caches/dev:/root \
	-w /app \
	$IMAGE $MICROS

# then run instructions in source folder:
# MICROS="dotnet run --server.urls http://0.0.0.0:5000" dotnet-runner.sh d1


