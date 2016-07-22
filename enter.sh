#!/bin/bash
if [ $# -lt 1 ]; then	
	echo "assign image name: [name=<container-name>] enter.sh <image-name> [port]"
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

if [ $# -gt 1 ]; then
	port="-p $2:$2"
fi

[ "$name" != "--rm" ] && echo "container name is $name" \
	&& name="--name=$name"

# subst
incl_dir="$(dirname "$0")"
. "$incl_dir/incl_images.sh"

# execute
case "${image}" in
	"help" )
		open "https://hub.docker.com/explore/"
	;;

	alpine|busybox )
		docker run $name -it -v $(pwd):/app \
			$NETWORK -w /app $port \
			$image sh
	;;

	* ) 
		echo "exec in image $image"
		docker run $name -it \
			-v $HOME/works:/works \
			-v $(pwd):/app \
			-v $HOME/bin/docker-ins:/docker-ins \
			$NETWORK -w /app $port \
			$image bash
	;;
esac


