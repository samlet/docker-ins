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
