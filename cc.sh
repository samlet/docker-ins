#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"cc-dev"}
IMAGE=${IMAGE:-"nile/dev"}
WORKDIR=${WORKDIR:-"/works/cc"}

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
		
		docker run -it --net=dev-net --name $INSTANCE \
			 -v $HOME/works:/works \
			 -v $docker_ins:/docker-ins \
			 -v $HOME/caches/dev:/root \
			 -v $HOME/caches/include:/usr/local/include \
			 $IMAGE bash

		## contains: build-essential, cmake, python
		## for microservice served framework:
		#	apt-get install libboost-dev libboost-system-dev libre2-dev ragel

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

	"run.cc" )
		if [ $# -gt 1 ]; then	
			program=$2
			g++ -std=c++11 -pthread $program.cc -o $program
			./$program
		fi
	;;

	"c++17" )
		if [ $# -gt 1 ]; then	
			program=$2
			docker run --rm -i \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				gcc:6.1 sh -c "g++ -std=c++1z -pthread $program.cc -o $program && \
					./$program \
				"
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
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
