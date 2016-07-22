#!/bin/bash

INSTANCE=${INSTANCE:-"some-es"}
IMAGE=${IMAGE:-"elasticsearch:2.3"}
WORKDIR=${WORKDIR:-"/works"}

########################
# neo4j container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )		
		docker volume create --name elasticsearch-volume
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			--publish=9200:9200 --publish=9300:9300 \
			--volume=elasticsearch-volume:/usr/share/elasticsearch/data \
		 	$IMAGE 
	;;

	"admin" )
		open http://localhost:9200
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
