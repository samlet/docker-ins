#!/bin/bash
if [ $# -lt 1 ]; then	
	echo "assign image name: [name=<container-name>] enter.sh <image-name or command> [port]"
	echo "available commands: help list.c rm.c"
	echo "for example: name=t.centos enter.sh centos"
	echo "---------------------"
	echo "2016.7.28 
		add volume /root support;
		add attach container support;
		add command list.c;
		"
	echo "node -> node:6"
	echo "postgres -> postgres:9.5"
	echo "ocaml -> ocaml/opam"
	echo "...."
	exit 0
fi

image=$1
port=""
NETWORK="--net=dev-net"
name=${name:-"--rm"}
container_name="unknown_container"

if [ $# -gt 1 ]; then
	port="-p $2:$2"
fi

[ "$name" != "--rm" ] && echo "container name is $name" \
	&& container_name=$name \
	&& name="--name=$name"

# subst
incl_dir="$(dirname "$0")"
. "$incl_dir/incl_images.sh"

source "$HOME/works/python/v3/myenv/bin/activate"
PATH=$HOME/works/python/v3:$PATH 

# execute
case "${image}" in
	"help" )
		open "https://hub.docker.com/explore/"
	;;

	"list.c" )
		container_procs.py -c t. list
	;;

	"rm.c" )
		if [ -n "$2" ]; then
			docker stop $2
			docker rm $2
			docker volume rm $2.root
		fi
	;;

	alpine|busybox )
		docker run $name -it -v $(pwd):/app \
			$NETWORK -w /app $port \
			$image sh
	;;


	* ) 
		if container_procs.py -c $container_name exists > /dev/null; then
			echo "exists $container_name, start and attach it"
			docker start -i $container_name
		else
			echo "create new container with image $image"	
			root_vol=""
			if [ "$container_name" != "unknown_container" ]; then
				root_vol="-v ${container_name}.root:/root"
				docker volume create --name ${container_name}.root
				echo "create volume for root folder: $root_vol"
			fi

			docker run $name -it \
				-v $HOME/works:/works \
				-v $(pwd):/app $root_vol \
				-v $HOME/bin/docker-ins:/docker-ins \
				$NETWORK -w /app $port \
				$image bash

			# ubuntu special process		
			if ([ "$image" == "ubuntu:16.04" ] && [ "$container_name" != "unknown_container" ]); then
				docker start $container_name			
				echo "sources.list has been update to aliyun"
				docker exec -it $container_name sh -c \
					"cp /works/ubuntu/xenial/aliyun.list /etc/apt/sources.list &&
						apt-get update
					"
				docker attach $container_name
			fi
		fi
	;;
esac


