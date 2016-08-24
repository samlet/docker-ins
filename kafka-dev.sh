#!/usr/bin/env bash

# https://hub.docker.com/r/wurstmeister/kafka/
# https://github.com/wurstmeister/kafka-docker
# wurstmeister/kafka:0.10.0.0
# wurstmeister/kafka:0.8.2.2


set -e

export KAFKA_ADVERTISED_HOST_NAME=`ifconfig en0 | grep 'inet ' | awk '{ print $2}'`
echo "kafka startup with host ip $KAFKA_ADVERTISED_HOST_NAME"
echo "~~ support options: stop, logs, i"
cd ~/works/docker/kafka

COMPOSE=$HOME/works/docker/kafka/docker-compose-dev.yml

if [ $# -lt 1 ]; then	
	docker-compose -f $COMPOSE up -d
else
	CMD="$*"
	if [[ "${CMD}" == stop ]]; then
		docker-compose -f $COMPOSE stop
	elif [[ "${CMD}" == logs ]]; then
		docker-compose -f $COMPOSE logs -f
	else
		echo "enter instance -> " $*	
		docker exec -it kafka_kafka_1 bash
	fi
fi

