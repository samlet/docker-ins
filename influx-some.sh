#!/bin/bash
## https://hub.docker.com/_/influxdb/

## port, net, name, volume
docker run --net=dev-net --name some-influx \
	-p 8083:8083 -p 8086:8086 \
	-v $HOME/srv/influxdb:/var/lib/influxdb \
	-d influxdb:0.13

## Creating a DB named mydb:
# 	$ curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
## Inserting into the DB:
#	$ curl -i -XPOST 'http://localhost:8086/write?db=mydb' 
#		--data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
