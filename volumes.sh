#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands:"
	echo "dangling, vol.tool [image]"
	exit -1
fi

docker_ins=$HOME/bin/docker-ins

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

	"vol.tool")
		image="nile/dev"
		if [ $# -gt 1 ]; then	
			image=$2						
		fi
		echo "use image $image perform operators ..."
		docker volume create --name vol.tool
		# use this container to perform copy operators
		# 要使用这个工具卷, 只需要: -v vol.tool:/opt/tool
		docker run --rm -it \
				--net=dev-net \
				-v $docker_ins:/docker-ins \
				-v $HOME/works:/works \
				-v $HOME/tools:/tools \
				-v vol.tool:/opt/tool \
				-v $(pwd):/app \
				-w /app \
				$image bash
		;;
	*)
		docker volume ls
		;;
esac
