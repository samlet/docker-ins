#!/bin/bash

set -e

INSTANCE=${INSTANCE:-"some-es"}
IMAGE=${IMAGE:-"elasticsearch:2.3"}
WORKDIR=${WORKDIR:-"/works"}

########################
# neo4j container
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
		docker volume create --name elasticsearch-volume
		docker run -d --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			--publish=9200:9200 --publish=9300:9300 \
			--volume=elasticsearch-volume:/usr/share/elasticsearch/data \
		 	$IMAGE 
	;;

	"start")
		docker restart some-es
		docker logs -f some-es
	;;

	"cluster")
		# https://github.com/itzg/dockerfiles/tree/master/elasticsearch
		
		# 9200 - HTTP REST
		# 9300 - Native transport

		# Volumes
		# /data - location of path.data
		# /conf - location of path.conf

		es="itzg/elasticsearch"
		docker run -d --name es0 -p 9200:9200 -p 9300:9300 \
			-e PLUGINS=elasticsearch/marvel/latest \
			$es
		docker run -d --name es1 --link es0 -e UNICAST_HOSTS=es0 $es
		docker run -d --name es2 --link es0 -e UNICAST_HOSTS=es0 $es

		docker logs -f es0
	;;

	"cluster.clean")
	;;

	"cluster.health")
		# check the cluster health, such as 
		curl http://localhost:9200/_cluster/health?pretty
	;;

	"single")
		es="itzg/elasticsearch"
		docker run -d --name es0 -p 9200:9200 -p 9300:9300 \
			-e PLUGINS=elasticsearch/marvel/latest \
			$es
		docker logs -f es0
	;;

	"compose")
		cd ~/works/docker/elasticsearch/compose
		docker-compose up
	;;

	"admin" )
		open http://localhost:9200
	;;

	"ping")
		curl 'http://localhost:9200/?pretty'
		echo "你能看到返回信息, 这说明你的ELasticsearch集群已经启动并且正常运行."
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
