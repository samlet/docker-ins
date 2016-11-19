#!/bin/bash

# refs: 
# 	https://hub.docker.com/_/erlang/
# 	https://hub.docker.com/_/elixir/
set -e


INSTANCE=${INSTANCE:-"erlang-dev"}
# the image is elixir-1.3.2 with erlang 19
IMAGE=${IMAGE:-"elixir:1.3.2"}
WORKDIR=${WORKDIR:-"/works/erlang"}

EXEC="docker exec -it $INSTANCE"

########################
# erlang&elixir container
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
		docker volume create --name erlang.root
		docker run -it --net=dev-net --name $INSTANCE \
			-h erlang.local \
			-v erlang.root:/root \
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC erl -name snode@erlang.local
		fi
	;;
	"repl.elixir" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC iex --name snode@erlang.local
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

	"create.elixir" )
		if [ $# -gt 1 ]; then	
			section=$2
			mix new $section
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
	
	"run" )
		topdir=$HOME/works/erlang/practice
		if [ $# -gt 1 ]; then	
			section=$2
			echo "compile and run ${section}.erl"
			erlc ${section}.erl

			libpath=" "
			for lib in $(ls $topdir/myapp/_build/default/lib); do
				libpath="$libpath $topdir/myapp/_build/default/lib/$lib/ebin/"
			done
			# eredis="myapp/_build/default/lib/eredis/ebin/"
			# echo "--> $libpath"

			ext="$HOME/works/erlang/practice_elixir/_build/dev/lib/practice_elixir/ebin"
			libpath="$libpath $ext"

			erl -noshell -pa $libpath -s $section start -s init stop
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
