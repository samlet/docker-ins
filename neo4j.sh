#!/bin/bash

INSTANCE=${INSTANCE:-"some-neo4j"}
IMAGE=${IMAGE:-"neo4j:3.0"}
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
		# By default, this requires you to login with neo4j/neo4j and change the password. 
		# You can, for development purposes, disable authentication by passing
		# --env=NEO4J_AUTH=none to docker run.
		# Change the password to: admin
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			--publish=7474:7474 --publish=7687:7687 \
			--volume=$HOME/srv/neo4j/data:/data \
		 	$IMAGE 
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
	;;

	"admin" )
		open http://localhost:7474
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
