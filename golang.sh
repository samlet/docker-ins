#!/bin/bash

# set -e

# https://hub.docker.com/_/golang/

INSTANCE=${INSTANCE:-"golang-dev"}
IMAGE=${IMAGE:-"golang:1.7"}
WORKDIR=${WORKDIR:-"/works/golang"}

EXEC="docker exec -it $INSTANCE"

########################
# golang container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins
ubuntu_container="$INSTANCE"

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker volume create --name golang.root		
		docker run -it --net=dev-net --name $INSTANCE \
			 -v $HOME/works:/works \
			 -v golang.root:/root \
			 -v $HOME/go/src:/go/src \
			 -e GOPATH=/go \
			 -w $WORKDIR \
			  $IMAGE /bin/bash
	;;	

	"repl.docker" )
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
		# golang
		if [ $# -gt 1 ]; then	
			program=$2
			killall $program > /dev/null 2>&1
			echo "build $program ..."
			export GOPATH=$HOME/go			
			go build $program.go
			cp $program $HOME/bin/mac/$program
			rm $program
			
			file=$program.run
			if [ -e "$file" ]; then
			    echo "execute $file ..."
			    bash $file
			else 
			    echo "run $program ..."
			    $HOME/bin/mac/$program
			fi 			
		fi
	;;


	"c.init" )
		image="ubuntu:16.04"
		docker run --name=$ubuntu_container -it \
				--net=dev-net \
				-v $HOME/works:/works \
				-v $HOME/bin/docker-ins:/docker-ins \
				-v $HOME/works/ubuntu/xenial/in-docker.list:/etc/apt/sources.list \
				-w /works \
				$image bash
	;;

	"c.enter" )
		docker start -i $ubuntu_container
	;;

	"c.exec" )
		# golang-exec
		# exec basic.c: $ cc.sh c.exec basic $(pwd)
		if [ $# -gt 2 ]; then	
			program=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}

			cmd="cd $docker_path ; \
				go build $program.go && \
				./$program \
				"
			if docker restart $ubuntu_container > /dev/null; then
				docker exec -i $ubuntu_container sh -c "$cmd"
			fi
		fi
	;;

	"c.single" )
		# golang-docker
		if [ $# -gt 1 ]; then	
			program=$2
			container_name="go.$program"
			docker rm -f $container_name > /dev/null
			docker run -d \
				--name=$container_name \
				--net=dev-net \
				-p 8080:8080 \
				-v $(pwd):/app \
				-w /app \
				golang:1.7 sh -c "go build $program.go && \
					./$program \
				"
			docker logs -f $container_name
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
