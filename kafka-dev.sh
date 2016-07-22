#!/usr/bin/env bash
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

