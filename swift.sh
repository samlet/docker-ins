#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"swift-dev"}
IMAGE=${IMAGE:-"nile/swift"}
WORKDIR=${WORKDIR:-"/works/swift"}

EXEC="docker exec -it $INSTANCE"

########################
# swift container
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
		docker run -it --net=dev-net --privileged --name $INSTANCE \
			-v $HOME/works:/works \
			-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"init.dev")
		exec ~/opt/bin/swift-dev.sh
	;;

	"install.vapor")
		# https://github.com/vapor/toolbox
		# install Vapor Toolbox
		brew install vapor/tap/toolbox

		# Linux
		# curl -sL toolbox.qutheory.io | bash
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC swift
		fi
	;;

	"l3")
		sudo xcode-select -s /Applications/Xcode-beta.app ; swift		
	;;

	"l2")
		sudo xcode-select -s /Applications/Xcode.app ; swift
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

	"run.stub" )
		# killall macros > /dev/null 2>&1 || echo "fresh!"
		topdir=$HOME/works/swift/practice
		if [ $# -gt 1 ]; then	
			section=$2
			echo "compile and run ${section}.swift with Package.swift ..."
			cp ${section}.swift $topdir/socks-projs/Socks-1.0.1/Sources/Console/main.swift
			cd $topdir/socks-projs/Socks-1.0.1			
			swift build
			# run it
			# ./.build/debug/Console

			# dist it 
			distloc="$HOME/bin/mac/$section"			
			cp $topdir/socks-projs/Socks-1.0.1/.build/debug/Console $distloc
			# echo "dist to $distloc ok."

			# run it
			cd $topdir
			exec $distloc
		fi
	;;

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://swift.org/download/#using-downloads"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, l2, l3, deps, s, stop, help" 
		echo "unknown: " $*
	;;
esac
