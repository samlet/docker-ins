#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"cc-dev"}
IMAGE=${IMAGE:-"nile/dev"}
WORKDIR=${WORKDIR:-"/works/cc"}

EXEC="docker exec -it $INSTANCE"

########################
# jruby container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins
mirror_sources="-v $HOME/works/ubuntu/xenial/in-docker.list:/etc/apt/sources.list"

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
			 -v $docker_ins:/docker-ins \
			 -v $HOME/caches/dev:/root \
			 -v $HOME/caches/include:/usr/local/include \
			 $IMAGE bash

		## contains: build-essential, cmake, python
		## for microservice served framework:
		#	apt-get install libboost-dev libboost-system-dev libre2-dev ragel

		# ...
		# 	apt-get install python-pip
		# https://github.com/conan-io/conan
		#	pip install conan

	;;

	"repl" )
		$HOME/works/cc/cling_2016-08-23_mac1011/bin/cling
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

	"run.cc" )
		if [ $# -gt 1 ]; then	
			program=$2
			g++ -std=c++11 -pthread \
				-L. -lredox -lev -lhiredis \
			 	$program.cc -o $program
			./$program
		fi
	;;

	"run.cmake" )
		if [ $# -gt 1 ]; then	
			topdir=$HOME/works/cc/practice
			section=$2

			file=CMakeLists.txt
			if [ -e "$file" ]; then
			    echo "re-exec with $file ..."
			    exec cc.sh cmake $section
			    # skip leave
			    exit 0
			fi

			# test accomplish program
			client_program="${section/server/client}"
			if test "$client_program" != "$section"; then			
				if [ -s $client_program ]; then
					echo "client program $client_program exists."
					cp ${client_program} $topdir/cmake/client.cxx
				fi
			fi

			echo "compile and run ${section} with cmake ..."
			cp ${section} $topdir/cmake/main.cxx

			mkdir -p $topdir/cmake/build
			cd $topdir/cmake/build
			cmake ..
			make

			distloc="$HOME/bin/mac/$section"
			cp ./practice $distloc

			( ./practice --logtostderr=1 & )
			if test "$client_program" != "$section"; then
				( ./client --logtostderr=1 )
			fi
		fi
	;;

	"cmake" )
		if [ $# -gt 1 ]; then
			section=$2
			mkdir -p build
			cd build
			cmake ..
			make

			cd ..
			bash ./exec.sh
		fi
	;;

	"c++11" )
		std_level="c++11"
		image="gcc:4.9"

		echo "compile with $image $std_level ..."
		
		if [ $# -gt 1 ]; then	
			program=$2
			docker run --rm -i \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				$image sh -c "g++ -std=$std_level -pthread $program.cc -o $program && \
					./$program \
				"
		fi
	;;

	"c++17" )
		std_level="c++1z"
		image="gcc:6.1"
		libs="-pthread"
		echo "compile with $image $std_level ..."
		
		if [ $# -gt 1 ]; then	
			program=$2
			docker run --rm -i \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				$image sh -c "g++ -std=$std_level $libs $program.cc -o $program && \
					./$program \
				"
		fi
	;;

	"c.init" )
		image="ubuntu:16.04"
		docker run --name=c.ubuntu -it \
				--net=dev-net \
				-v $HOME/works:/works \
				-v $HOME/bin/docker-ins:/docker-ins \
				-v $HOME/works/ubuntu/xenial/in-docker.list:/etc/apt/sources.list \
				-w /works/c \
				$image bash
	;;

	"c.enter" )
		docker start -i c.ubuntu
	;;

	"c.exec" )
		# exec basic.c: $ cc.sh c.exec basic $(pwd)
		if [ $# -gt 2 ]; then	
			program=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}

			cmd="cd $docker_path ; gcc -std=c11 -pthread $program.c -o $program && \
						./$program \
					"
			if docker restart c.ubuntu > /dev/null; then
				docker exec -i c.ubuntu sh -c "$cmd"
			fi
		fi
	;;

	"c.single" )
		if [ $# -gt 1 ]; then	
			program=$2
			docker run --rm -i \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				gcc:6.1 sh -c "gcc -std=c11 -pthread $program.c -o $program && \
					./$program \
				"
		fi
	;;

	"+local" )
		echo "run c++ microservice docker with /usr/local ..."
		docker run --rm -it --net=dev-net \
				-v $(pwd):/app -w /app \
				-v $HOME/works/cc/linux.ubuntu.1604/local:/usr/local \
				nile/cc-micros bash
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
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
