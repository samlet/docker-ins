#!/bin/bash

# refs: https://hub.docker.com/_/nginx/

set -e


INSTANCE=${INSTANCE:-"some-nginx"}
IMAGE=${IMAGE:-"nginx:1.11"}
WORKDIR=${WORKDIR:-"/works/web"}

EXEC="docker exec -it $INSTANCE"

########################
# nginx container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

volume_name=nginx.store
opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker run -d --net=dev-net --name $INSTANCE \
			-p 80:80 \
			-v $HOME/works:/works \
			-v $HOME/works/web:/usr/share/nginx/html \
			-w $WORKDIR \
		 	$IMAGE 
	;;

	"get-default")
		docker start some-nginx
		docker cp some-nginx:/etc/nginx/nginx.conf ./nginx.conf.default
	;;

	"help")
		open "https://hub.docker.com/_/nginx/"
	;;

	"vol.create")
		docker volume create --name $volume_name
	;;

	* ) 
		echo "available options: new, init, get-default"
		echo "unknown: " $*
	;;
esac
