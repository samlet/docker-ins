#!/bin/bash
## https://hub.docker.com/_/cassandra/

## port, net, name, volume

## use volume instead of a folder, for privillege problem, 
## the data folder need cassandra:cassandra privillege
docker volume create --name cassandra-volume
# $ docker volume create -d flocker --name my-named-volume -o size=20GB
docker run --net=dev-net --name some-cassandra \
	-p 7000:7000 \
	-v cassandra-volume:/var/lib/cassandra \
	-d cassandra:3.5


# Make a cluster
# $ docker run --name some-cassandra2 -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' some-cassandra)" cassandra:tag
# $ docker run --name some-cassandra2 -d --link some-cassandra:cassandra cassandra:tag

## For separate machines (ie, two VMs on a cloud provider)
# Assuming the first machine's IP address is 10.42.42.42 and the second's is 10.43.43.43, start the first with exposed gossip port:
# $ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.42.42.42 -p 7000:7000 cassandra:tag
# Then start a Cassandra container on the second machine, with the exposed gossip port and seed pointing to the first machine:
# $ docker run --name some-cassandra -d -e CASSANDRA_BROADCAST_ADDRESS=10.43.43.43 -p 7000:7000 -e CASSANDRA_SEEDS=10.42.42.42 cassandra:tag
