#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-cassandra"}
IMAGE=${IMAGE:-"cassandra:3.9"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# cassandra container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run -itd --net=dev-net --name cassandra_1 \
        	-p 7000:7000 -p 7001:7001 -p 7199:7199 \
			-p 9160:9160 -p 9042:9042 \
        	-v $HOME/works:/works \
        	$IMAGE 
        docker logs -f cassandra_1
        exit
    ;;

    "remove" )
		docker stop cassandra_1
		docker rm cassandra_1
	;;

    "init" )
		## https://hub.docker.com/_/cassandra/

		## port, net, name, volume

		# 7000: intra-node communication
		# 7001: TLS intra-node communication
		# 7199: JMX
		# 9042: CQL
		# 9160: thrift service

		## use volume instead of a folder, for privillege problem, 
		## the data folder need cassandra:cassandra privillege
		docker volume create --name cassandra-volume
		# $ docker volume create -d flocker --name my-named-volume -o size=20GB
		docker run --net=dev-net --name $INSTANCE \
			-p 7000:7000 -p 7001:7001 -p 7199:7199 \
			-p 9160:9160 -p 9042:9042 \
			-v $HOME/works:/works \
			-v cassandra-volume:/var/lib/cassandra \
			-d $IMAGE

		docker logs -f $INSTANCE

		# Make a cluster
		# $ docker run --name some-cassandra2 -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' some-cassandra)" cassandra:tag
		# $ docker run --name some-cassandra2 -d --link some-cassandra:cassandra cassandra:tag

		## For separate machines (ie, two VMs on a cloud provider)
		# Assuming the first machine's IP address is 10.42.42.42 and the second's is 10.43.43.43, start the first with exposed gossip port:
		# $ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.42.42.42 -p 7000:7000 cassandra:tag
		# Then start a Cassandra container on the second machine, with the exposed gossip port and seed pointing to the first machine:
		# $ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.43.43.43 -p 7000:7000 -e CASSANDRA_SEEDS=10.42.42.42 cassandra:tag

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			# http://wiki.apache.org/cassandra/GettingStarted
			$EXEC cqlsh
		fi
	;;

	"daemon" )
		echo "start a backend ..."
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
	;;

	"seeds" )
		$EXEC cqlsh -e "CREATE KEYSPACE mykeyspace \
			WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }; \
			USE mykeyspace; \
			CREATE TABLE users ( \
			  user_id int PRIMARY KEY, \
			  fname text, \
			  lname text \
			); \

			INSERT INTO users (user_id,  fname, lname) \
			  VALUES (1745, 'john', 'smith'); \
			INSERT INTO users (user_id,  fname, lname) \
			  VALUES (1744, 'john', 'doe'); \
			INSERT INTO users (user_id,  fname, lname) \
			  VALUES (1746, 'john', 'smith'); "

	;;

	"seeds.query" )
		$EXEC cqlsh -e "use mykeyspace; select * from users;"
	;;

	"seeds.index" )
		$EXEC cqlsh -e "use mykeyspace; CREATE INDEX ON users (lname); \
			SELECT * FROM users WHERE lname = 'smith';"
	;;

	"ruby" )
		
	;;

	"python" )
		python_exec=$HOME/works/python/practice/cassandra_procs/bin/python
		exec $python_exec
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
