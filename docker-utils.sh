#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: host, install, run, ..."
	exit -1
fi

CMD=$1
case "$CMD" in
	"host")		
		# https://blog.bennycornelissen.nl/docker-for-mac-neat-fast-and-flawed/
		screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
		# Now, in the blank screen I need to type login=root according to docs, but in reality I just need to press enter to get a login prompt.
		;;
	"ip")
		# http://superuser.com/questions/1080151/what-is-my-containers-ip-number-using-docker-beta-for-mac
		# the IP address inside the container which is 172.17.0.2 and only exists "inside" the docker containers (and between them).
		KAFKA_ADVERTISED_HOST_NAME=$(docker run --rm debian:jessie ip route | awk '/^default via / { print $3 }')
		echo $KAFKA_ADVERTISED_HOST_NAME
		;;	
	"run")
		if [ $# -gt 1 ]; then	
			target=$2
			echo "run $target ..."
		else
			echo "use: ...."
		fi
		;;

	"list-dangling")
		docker images -f "dangling=true"
		;;
	"clean-none")
		# https://forums.docker.com/t/how-to-remove-none-images-after-building/7050/6
		docker rmi $(docker images -f "dangling=true" -q)
		;;
	*)
		# docker volume ls
		;;
esac
