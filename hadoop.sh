#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"hadoop-master"}
IMAGE=${IMAGE:-"kiwenlau/hadoop:1.0"}
WORKDIR=${WORKDIR:-"/works/hadoop"}

EXEC="docker exec -it $INSTANCE"

########################
# hadoop container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
opt=$1

N=${1:-3}
index=1

case "${opt}" in    

	"stop" )
		docker stop $INSTANCE
		
		#while [ ${index} -lt $N ]
		#do
		#	docker stop hadoop-slave$index
		#	index=$(( $index + 1 ))
		#done 
		docker stop hadoop-slave1
		docker stop hadoop-slave2
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC bash
		fi
	;;

	"cluster" )		
		$incl_dir/hadoop/start-cluster.sh	
		$EXEC /root/start-hadoop.sh
	;;

	"tests" )
		$EXEC /root/run-wordcount.sh
	;;

	"admin" )
		open "http://localhost:8088/"
		open "http://localhost:50070/"
	;;

	"files" )
		open "http://localhost:50070/explorer.html"
	;;

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://github.com/kiwenlau/hadoop-cluster-docker"
			open "http://kiwenlau.com/2016/06/12/160612-hadoop-cluster-docker-update/"
		fi
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
