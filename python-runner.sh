#!/bin/bash
set -e
INSTANCE=python-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-9000}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/app \
	-p $PORT:80 \
	-v $HOME/caches/dev:/root \
	-w /app \
	nile/python:2.7 $MICROS

# then run instructions in source folder:
# MICROS="python app.py" python-runner.sh p1


