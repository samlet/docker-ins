#!/bin/bash

INSTANCE=${INSTANCE:-"haskell-dev"}
IMAGE=${IMAGE:-"haskell:8"}
WORKDIR=${WORKDIR:-"/works/haskell"}

########################
# haskell container
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
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"local.init" )
		brew install ghc cabal-install && \
			cabal update && \
			cabal install ghc-mod && \
			ghci

	;;

	"repl" )
		docker start $INSTANCE
		docker exec -it $INSTANCE ghci
	;;

	"l.repl" )
		ghci
	;;

	"play" )
		echo "open http://localhost:4001/"
		docker run -it --rm --net=dev-net \
			-v $HOME/works/haskell/tryhaskell:/app \
			-p 4001:4001 \
			-w /app \
			nile/haskell ./runit.sh
		# open "http://localhost:4001/"
	;;

	* ) 
		echo "available options: new, init" $*
	;;
esac
