#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

CMD=$1
case "$CMD" in
	"dangling")		
		# docker volume ls -f dangling=true		
		;;
	"sample")
		# 
		;;	
	"backup")
		if [ $# -gt 2 ]; then	
			# 
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;
	*)
		# docker volume ls
		;;
esac
