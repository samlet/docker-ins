#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-zk"}
# base: java:openjdk-8-jre-alpine
IMAGE=${IMAGE:-"jplock/zookeeper:3.4.8"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# jruby container
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
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works/zookeeper:/local \
			-v $docker_ins:/docker-ins \
			-p 2181:2181 -p 2888:2888 -p 3888:3888 \
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
			open "https://hub.docker.com/r/jplock/zookeeper/tags/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
