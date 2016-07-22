#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

CMD=$1
case "$CMD" in
	"dangling")		
		docker volume ls -f dangling=true		
		;;
	"sample")
		docker create -v /dbdata --name dbstore training/postgres /bin/true
		docker run -d --volumes-from dbstore --name db1 training/postgres
		docker run -d --volumes-from dbstore --name db2 training/postgres
		docker run -d --name db3 --volumes-from db1 training/postgres
		;;	
	"backup")
		if [ $# -gt 2 ]; then	
			vol=$2
			folder=$3
			docker run --rm --volumes-from $vol -v $(pwd):/backup \
				ubuntu tar cvf /backup/$vol.tar $folder
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;
	*)
		docker volume ls
		;;
esac
