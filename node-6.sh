#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"node-6"}
IMAGE=${IMAGE:-"node:6"}
WORKDIR=${WORKDIR:-"/works/node.js"}

EXEC="docker exec -it $INSTANCE"

########################
# node.js container
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
		docker run -it --net=dev-net --name node-6 -v $HOME/works:/works \
		 -v $HOME/caches/npm.6:/root/.npm \
		 -w /works/microservices/node.js \
		  node:6 /bin/bash

		## additional packages
		#	apt-get install vim

	;;

	"install.tools" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC sh -c "apt-get update && \
				apt-get -y install vim
			"
		fi
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC node
		fi
	;;

	"alpine.version")
		docker run --rm mhart/alpine-node node --version
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
