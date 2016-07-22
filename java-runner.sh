#!/bin/bash
set -e
INSTANCE=java-inst

if [ $# -lt 1 ]; then	
	docker rm $INSTANCE
else
	INSTANCE="$*"	
fi

MICROS=${MICROS:-"/bin/bash"}
PORT=${PORT:-8080}
IMAGE=${IMAGE:-"nile/java-dev"}

echo "run instance -> " $MICROS $PORT	

docker run -it --rm --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-v $(pwd):/app \
	-p $PORT:8080 \
	-v $HOME/caches/dev:/root \
	-w /app \
	$IMAGE $MICROS

# then run instructions in source folder:
# MICROS="sh start.sh" java-runner.sh j1
# MICROS="sh start.sh" PORT=9090 java-runner.sh j2

# MICROS="sbt run" IMAGE="nile/scala-dev" PORT=8080 java-runner.sh j3

