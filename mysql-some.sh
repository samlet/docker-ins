#!/bin/bash
## https://hub.docker.com/_/mysql/

## port, net, name, volume
docker run --net=dev-net --name some-mysql \
	-p 3306:3306 \
	-v $HOME/srv/mysql:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=root -d mysql:5.7

## $ docker exec -it some-mysql bash
## # mysql -uroot -proot
