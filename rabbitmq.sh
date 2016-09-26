#!/bin/bash

INSTANCE=${INSTANCE:-"some-rabbit"}
IMAGE=${IMAGE:-"rabbitmq:3.6"}
WORKDIR=${WORKDIR:-"/works"}

########################
# rabbitmq container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

EXEC="docker exec -it $INSTANCE"
opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker run --net=dev-net --name some-rabbit \
			-e RABBITMQ_ERLANG_COOKIE='secret cookie here' \
			-p 5672:5672 \
			-d $IMAGE
	;;

	"bindings" )
		$EXEC rabbitmqctl list_bindings
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac


