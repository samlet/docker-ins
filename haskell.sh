#!/bin/bash

INSTANCE=${INSTANCE:-"haskell-dev"}
IMAGE=${IMAGE:-"haskell:8"}
WORKDIR=${WORKDIR:-"/works/haskell"}

########################
# haskell container
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
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"repl" )
		docker start $INSTANCE
		docker exec -it $INSTANCE ghci
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
