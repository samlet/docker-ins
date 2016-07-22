#!/bin/bash
## ref: https://hub.docker.com/_/rabbitmq/
## port, net, name, volume

docker run --net=dev-net --name some-rabbit \
	-e RABBITMQ_ERLANG_COOKIE='secret cookie here' \
	-p 5672:5672 \
	-d rabbitmq:3.6

## There is a second set of tags provided with the management plugin installed 
## and enabled by default, which is available on the standard management 
## port of 15672, with the default username and password of guest / guest:

# docker run -d --hostname my-rabbit --name some-rabbit -p 15672:15672 \
#	rabbitmq:3-management

