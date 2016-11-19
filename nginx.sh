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

	"start-proxy")
		# https://github.com/jwilder/nginx-proxy
		# Multiple Networks

		# With the addition of overlay networking in Docker 1.9, your nginx-proxy container may need to connect to backend containers on multiple networks. By default, if you don't pass the --net flag when your nginx-proxy container is created, it will only be attached to the default bridge network. This means that it will not be able to connect to containers on networks other than bridge.

		# If you want your nginx-proxy container to be attached to a different network, you must pass the --net=my-network option in your docker create or docker run command. At the time of this writing, only a single network can be specified at container creation time. To attach to other networks, you can use the docker network connect command after your container is created:

		docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro \
    		--name nginx-proxy --net dev-net jwilder/nginx-proxy

    	docker run -d -e VIRTUAL_HOST=whoami.local \
    		--name whoami --net dev-net jwilder/whoami

    	echo "wait starting, and then test whoami service ..."
    	sleep 2

    	echo "... if add '127.0.0.1	whoami.local' to /etc/hosts, visit the http://whoami.local on browser"
    	echo ".. or type 'open http://whoami.local' to browse"
    	curl -H "Host: whoami.local" localhost
	;;

	"stop-proxy")
		docker stop nginx-proxy
		docker rm nginx-proxy

		docker stop whoami		
		docker rm whoami
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
