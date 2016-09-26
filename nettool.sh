#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	echo "availables: port, port.all"
	exit -1
fi

CMD=$1
case "$CMD" in
	"dangling")		
		# docker volume ls -f dangling=true		
		;;
	"port")
		# http://stackoverflow.com/questions/4421633/who-is-listening-on-a-given-tcp-port-on-mac-os-x
		PORT=8080
		if [ $# -gt 1 ]; then				
			PORT=$2			
		fi
		lsof -n -i4TCP:$PORT | grep LISTEN
		;;	
	"port.all")
		# lsof -i -n -P | grep TCP
		lsof -iTCP -sTCP:LISTEN -n -P
		;;
	"backup")
		if [ $# -gt 2 ]; then	
			echo "backup ..."
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;
	*)
		# docker volume ls
		;;
esac
