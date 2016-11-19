#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

CMD=$1

# kafka_2.11-0.10.0.0
kafka_env(){
	export KAFKA_ADVERTISED_HOST_NAME=`ifconfig en0 | grep 'inet ' | awk '{ print $2}'`
	COMPOSE=$HOME/works/docker/kafka/docker-compose-dev.yml
	KAFKA="docker-compose -f $COMPOSE exec kafka"
	kafka_topics="/opt/kafka_2.11-0.10.0.0/bin/kafka-topics.sh"

	cd ~/works/docker/kafka
}

case "$CMD" in
	"start")		
		kafka-dev.sh 
		kafka-dev.sh logs
		;;
	"stop")
		kafka-dev.sh stop 
		;;	
	"bash")
		kafka-dev.sh bash
		;;

	"list.topics")
		kafka_env		
		$KAFKA $kafka_topics --list --zookeeper zookeeper:2181
		;;
	"create.topic")
		# ./dockerize create.topic summary-markers
		if [ $# -gt 1 ]; then	
			kafka_env
			target=$2
			$KAFKA $kafka_topics --create --zookeeper zookeeper:2181 \
	       		--replication-factor 1 --partitions 1 --topic $target
	    else
	    	echo "create.topic <target>"
	    fi
		;;

	"clean")
		kafka_env
		docker-compose -f $COMPOSE stop
		docker-compose -f $COMPOSE rm -vf
		;;

	"ps")
		kafka_env
		docker-compose -f $COMPOSE ps
		;;
		
	"run")
		if [ $# -gt 1 ]; then	
			target=$2
			echo "run $target ..."
		else
			echo "use: ...."
		fi
		;;

	"practice.java")
		cd ~/works/kafka/practice/kafka-sample-programs

		kafka.sh create.topic fast-messages || echo "skip create"
		kafka.sh create.topic summary-markers || echo "skip create"
		echo "all topics:"
		kafka.sh list.topics

		mvn package
		target/kafka-example producer &
		target/kafka-example consumer
		;;
	*)
		# docker volume ls
		;;
esac
