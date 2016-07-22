#!/bin/bash

INSTANCE=${INSTANCE:-"jruby-dev"}
IMAGE=${IMAGE:-"jruby:9.1-jdk"}
WORKDIR=${WORKDIR:-"/works/jruby"}

########################
# jruby container
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

	* ) 
		echo "available options: new, init" $*
	;;
esac
