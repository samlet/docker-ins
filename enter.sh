#!/bin/bash
if [ $# -lt 1 ]; then	
	echo "assign image name: [name=<container-name>] enter.sh <image-name or command> [port]"
	echo "available commands: help list.c"
	echo "for example: name=t.centos enter.sh centos"
	echo "---------------------"
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
			docker run $name -it \
				-v $HOME/works:/works \
				-v $(pwd):/app \
				-v $HOME/bin/docker-ins:/docker-ins \
				$NETWORK -w /app $port \
				$image bash
		fi
	;;
esac


