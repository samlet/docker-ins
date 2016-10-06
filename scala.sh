#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"scala-dev"}
IMAGE=${IMAGE:-"nile/java-dev"}
WORKDIR=${WORKDIR:-"/works/scala"}

EXEC="docker exec -it $INSTANCE"

########################
# scala container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins
ubuntu_container=c.ubuntu

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
			-v $HOME/works:/works \
		 	-v $HOME/caches/dev:/root \
		 	-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		 	$IMAGE bash

		## contains: java 8, gradle, maven
		## for scala: download sbt, and copy sbt/bin/* to /usr/local/bin/

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC scala
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
		# exec basic.c: $ cc.sh c.exec basic $(pwd)
		if [ $# -gt 2 ]; then	
			program=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}

			cmd="cd $docker_path ; \
				gcc -std=c11 -pthread $program.c -o $program && \
				./$program \
				"
			if docker restart $ubuntu_container > /dev/null; then
				docker exec -i $ubuntu_container sh -c "$cmd"
			fi
		fi
	;;

	"c.single" )
		if [ $# -gt 1 ]; then	
			program=$2
			container_name="go.$program"
			docker rm -f $container_name > /dev/null
			docker run -d \
				--name=$container_name \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				golang:1.7 sh -c "go build $program.go && \
					./$program \
				"
			docker logs -f $container_name
		fi
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
		# 使用scala sbt来运行指定的源文件, 如果parent folder starts with "_", 则将复制目录下所有的源文件至scala/module目录下
		
		topdir=$HOME/works/scala/scripts
		if [ $# -gt 1 ]; then	
			section=$2
			# printf '%s\n' "${PWD##*/}"
			parent=${PWD##*/}

			if [[ $parent == _* ]] ; then
				echo "copy module sources and build ..."
				# remove single main file
				rm -f $topdir/macros/src/main/scala/main.scala
				rm -rf $topdir/macros/src/main/scala/module/*
				cp -r * $topdir/macros/src/main/scala/module/
			else
				echo "compile and run ${section}.scala ..."
				rm -rf $topdir/macros/src/main/scala/module/*
				cp ${section}.scala $topdir/macros/src/main/scala/main.scala
				# cp helper*.scala $topdir/macros/src/main/scala/
			fi
			
			cd $topdir/macros
			sbt -no-colors run
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
