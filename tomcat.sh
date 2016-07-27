#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"tomcat-dev"}
IMAGE=${IMAGE:-"tomcat:8.5"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# tomcat container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
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
		# docker volume create --name elasticsearch-volume
		docker run -it --net=dev-net --name $INSTANCE \
			-p 8080:8080 \
			-v $HOME/works:/works \
			-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		 	$IMAGE 
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC redis-cli
		fi
	;;

	"deps" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC opam depext -i cohttp lwt ssl
		fi
	;;

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/_/tomcat/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
