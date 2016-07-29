#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"python-3.5"}
IMAGE=${IMAGE:-"python:3.5"}
WORKDIR=${WORKDIR:-"/works/python"}

EXEC="docker exec -it $INSTANCE"

########################
# python container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins

source "$HOME/works/python/v3/myenv/bin/activate"
PATH=$HOME/works/python/v3:$PATH 
export PYTHONPATH=$HOME/bin/python

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		# docker volume create --name python3-volume
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
		 	-v $HOME/caches/python.3:/root \
		 	-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		  	$IMAGE bash

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC python
		fi
	;;

	"repl.local" )
		pip list
		python
	;;

	"install.local" )
		# $ python-3.5.sh install.local redis mongo
		argstart=2		
		pip install ${@:$argstart}
	;;

	"deps" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC pip install redis
		fi
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
	;;
	
	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/_/erlang/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, repl.local, install.local, deps, help" 
		echo "unknown: " $*
	;;
esac
