#!/bin/bash
## ref: https://hub.docker.com/_/mongo/
## port, net, name, volume

docker run --net=dev-net --name some-mongo \
	-p 27017:27017 \
	-v $HOME/srv/mongo:/data/db -d mongo:3.3

