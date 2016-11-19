#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"alpine-dev"}
IMAGE=${IMAGE:-"alpine:3.4"}
WORKDIR=${WORKDIR:-"/works/docker/alpine"}

EXEC="docker exec -it $INSTANCE"

########################
# jruby container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE sh
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
		# docker volume create --name rust.root
		#	 with: -v rust.root:/root \
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		 	$IMAGE sh

		# additional steps
		# apk update
		# apk add mysql-client
		# apk add nginx php5-fpm
		# apk add php5-mysql

		# -- mysql
		# mysql -h some-mysql -u root -proot
		# > show databases
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
