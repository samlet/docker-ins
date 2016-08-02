#!/bin/bash

# ref: https://hub.docker.com/_/erlang/
set -e


INSTANCE=${INSTANCE:-"erlang-dev"}
IMAGE=${IMAGE:-"erlang:19"}
WORKDIR=${WORKDIR:-"/works/erlang"}

EXEC="docker exec -it $INSTANCE"

########################
# erlang container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker run -it --net=dev-net --name $INSTANCE \
			-h erlang.local \
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC erl -name snode@erlang.local
		fi
	;;

	"docker.run" )
		if docker start $INSTANCE > /dev/null; then
			if [ $# -gt 1 ]; then	
				section=$2
				$EXEC escript $section
			fi
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

	"install.macos" )
		brew install erlang
	;;

	"create" )
		# http://www.rebar3.org/docs/basic-usage
		if [ $# -gt 1 ]; then	
			section=$2
			rebar3 new app $section
		fi
	;;

	"run" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "compile and run ${section}.erl"
			erlc ${section}.erl
			erl -noshell -s $section start -s init stop
		fi
	;;

	"build" )
		rebar3 compile
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
