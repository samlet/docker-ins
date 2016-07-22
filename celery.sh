#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-celery"}
IMAGE=${IMAGE:-"celery:3.1"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# celery container
########################

if [ $# -lt 1 ]; then	
	docker start some-rabbit
	docker start some-redis

	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run --net=dev-net --link some-rabbit:rabbit --name some-celery -d celery
        exit
    ;;

    "init" )
		docker run -it --net=dev-net --name $INSTANCE \
			--link some-rabbit:rabbit \
			--link some-redis:redis \
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"install-client")
		if docker start python-3.5 > /dev/null; then
			docker exec python-3.5 sh -c "pip install redis && \
				pip install celery && \
				echo 'available packages:' && \
				pip list"
		fi
	;;

	"simple" )		
		docker run --rm --net=dev-net \
			--link some-rabbit:rabbit \
			--link some-redis:redis \
			-v $HOME/works:/works \
			-w $WORKDIR/python/practice/celery/simple \
		 	$IMAGE celery -A tasks worker --loglevel=info

	;;

	"simple.s" )
		if docker start python-3.5 > /dev/null; then
			docker exec python-3.5 sh -c "cd /works/python/practice/celery/simple && \
				C_FORCE_ROOT=1 celery -A tasks worker --loglevel=info
			"
		fi
	;;

	"simple.call" )
		# http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html
		if docker start python-3.5 > /dev/null; then
			docker exec python-3.5 python /works/python/practice/celery/simple/task_caller.py
		fi
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
