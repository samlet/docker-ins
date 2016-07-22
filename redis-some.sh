#!/bin/bash
## ref: https://hub.docker.com/_/redis/
## port, net, name, volume

docker run --net=dev-net --name some-redis \
	-p 6379:6379 \
	-d redis:3.2

# docker run --name some-redis \
# 	-v $HOME/srv/redis:/data \
# 	-d redis redis-server --appendonly yes 

