#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-solr"}
IMAGE=${IMAGE:-"solr:6.1"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# solr container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins

local_root=$HOME/works/solr/solr-6.1.0
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
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-v $docker_ins:/docker-ins \
			-p 8983:8983 \
			-w $WORKDIR \
		 	$IMAGE 
		 docker logs -f $INSTANCE
	;;

	"s.local" )
		cd local_root
		#   bin/solr -e <EXAMPLE> where <EXAMPLE> is one of:  
    	#		cloud        : SolrCloud example
    	#	    dih          : Data Import Handler (rdbms, mail, rss, tika)
    	#	    schemaless   : Schema-less example (schema is inferred from data during indexing)
    	#	    techproducts : Kitchen sink example providing comprehensive examples of Solr features
		bin/solr -e cloud
	;;

	"stop.local" )
		cd local_root
		bin/solr stop -all
	;;

	"admin" )
		open "http://localhost:8983/solr/"
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

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/_/solr/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
