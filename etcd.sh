#!/bin/bash

INSTANCE=${INSTANCE:-"some-etcd"}
IMAGE=${IMAGE:-"quay.io/coreos/etcd:v3.0.0"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# etcd container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE sh
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE sh
        exit
    ;;

    "init" )
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-w $WORKDIR \
			-p 2379:2379 \
			-e ETCDCTL_API=3 \
		 	$IMAGE 
	;;

	"test" )
		# To try out etcdctl
		$EXEC etcdctl --endpoints=localhost:2379 put foo "bar"
		$EXEC etcdctl --endpoints=localhost:2379 get foo
	;;

	* ) 
		echo "available options: new, init, test" $*
	;;
esac
