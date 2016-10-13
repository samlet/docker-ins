#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

CMD=$1
case "$CMD" in
	"init")		
		# docker volume ls -f dangling=true		
		;;
	"install")
		# 
		;;	
	"run")
		if [ $# -gt 1 ]; then	
			target=$2
			echo "run $target ..."
		else
			echo "use: ...."
		fi
		;;
	*)
		# docker volume ls
		;;
esac
