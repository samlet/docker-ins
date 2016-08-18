#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"rust-dev"}
IMAGE=${IMAGE:-"scorpil/rust:1.9"}
WORKDIR=${WORKDIR:-"/works/rust"}

EXEC="docker exec -it $INSTANCE"

########################
# rust container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		# docker volume create --name elasticsearch-volume
		docker run -it --net=dev-net --name $INSTANCE \
		 	 -v $docker_ins:/docker-ins \
		 	 -v $HOME/works:/works \
			 -v $HOME/caches/dev:/root \
			 -v $HOME/caches/include:/usr/local/include \
			 -w $WORKDIR \
			 $IMAGE bash

		## base image: debian:jessie
		## install packages
		##	apt-get install libsnappy-dev

		## for rust-bindgen (Clang >= 3.5): https://github.com/crabtw/rust-bindgen
		#	apt-get install clang libclang-dev liblua5.2-dev lua5.2 
		#	cargo install bindgen
		#
		#	append lines to /root/.bashrc:
		#		export PATH=$PATH:/root/.cargo/bin
		#	Generate a Lua binding with the CLI:
		#		bindgen --link lua --builtins /usr/include/lua5.2/lua.h --output=lua.rs

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC redis-cli
		fi
	;;

	"deps" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC opam depext -i cohttp lwt ssl
		fi
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
	;;


	"run" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "compile and run ${section}.rs"
			rustc ${section}.rs
			./$section
		fi
	;;

	"run.stub" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "compile and run ${section}.rs"
			cp ${section}.rs ./macros/src/main.rs
			cd ./macros
			cargo run
		fi
	;;

	
	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/_/erlang/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
