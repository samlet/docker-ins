#!/bin/bash

set -e

INSTANCE=${INSTANCE:-"some-mongo"}
IMAGE=${IMAGE:-"mongo:3.3"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# mongo container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

docker_ins=$HOME/bin/docker-ins
opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker volume create --name mongo-volume
		docker run --net=dev-net --name some-mongo \
			-p 27017:27017 \
			-v $docker_ins:/docker-ins \
			-v mongo-volume:/data/db -d mongo:3.3

	;;

	"install-client")
		if docker start python-3.5 > /dev/null; then
			docker exec python-3.5 sh -c "pip install pymongo && \
				echo 'available packages:' && \
				pip list"
		fi
	;;

	"test" )
		if docker start python-3.5 > /dev/null; then
			# https://docs.mongodb.com/getting-started/python/insert/
			docker exec python-3.5 python /works/python/mongo/tests.py
		fi
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
