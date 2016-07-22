#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"ocaml-dev"}
IMAGE=${IMAGE:-"ocaml/opam"}
WORKDIR=${WORKDIR:-"/works/ocaml"}

EXEC="docker exec -it $INSTANCE"

########################
# ocaml container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE 
        exit
    ;;

    "init" )
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-w $WORKDIR \
		 	$IMAGE bash
	;;

	"repl" )
		cd $HOME/works/ocaml
		utop
	;;

	"macos" )
		brew install ocaml opam rlwrap
		opam init
		printenv OCAML_TOPLEVEL_PATH
		opam install core utop
		opam install \
		   async yojson core_extended core_bench \
		   cohttp async_graphics cryptokit menhir

		cp $incl_dir/ocaml/.ocamlinit $HOME/.ocamlinit
	;;

	"deps" )
		# https://opam.ocaml.org/doc/FAQ.html
		# They probably depend on system, non-OCaml libraries: 
		# they need to be installed using your system package manager 
		# (apt-get, yum, pacman, homebrew, etc.) 
		# since they are outside the scope of OPAM. 
		# These external dependencies ("depexts") are in the process of 
		# being documented in the package repository, 
		# and the opam-depext tool should take care of that for you
		if docker start $INSTANCE > /dev/null; then
			$EXEC opam depext -i cohttp lwt ssl core utop
		fi
	;;

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/r/ocaml/opam/"
		fi
	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
