#!/bin/bash

# set -e

INSTANCE=${INSTANCE:-"python-3.5"}
IMAGE=${IMAGE:-"python:3.5"}
WORKDIR=${WORKDIR:-"/works/python"}

EXEC="docker exec -it $INSTANCE"

########################
# python container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins

# source "$HOME/works/python/v3/myenv/bin/activate"
export PYTHONPATH=$HOME/bin/python
PATH=$HOME/works/python/v3:$PATH 

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		# docker volume create --name python3-volume
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
		 	-v $HOME/caches/python.3:/root \
		 	-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		  	$IMAGE bash

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC python
		fi
	;;

	"repl.local" )
		pip list
		python
	;;

	"install.local" )
		# $ python-3.5.sh install.local redis mongo
		argstart=2		
		pip install ${@:$argstart}
	;;

	"deps" )
		# execute this section on project folder
		if docker start $INSTANCE > /dev/null; then
			# $EXEC pip install redis
			full_path=$(pwd)
			docker_path=${full_path/#${HOME}/}
			$EXEC sh -c "cd $docker_path ; \
				pip install -r requirements.txt"
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
			killall Python > /dev/null 2>&1

			section=$2
			echo "compile and run ${section}.py ..."
			python3 ${section}.py			
		fi
	;;

	"run.virtualenv")
		if [ $# -gt 1 ]; then
			section=$2
			echo "compile and run ${section} with virtualenv ..."
			./bin/python ${section}			
		fi
	;;
	
	"practice" )
		# top_dir=/works/python/practice/v3
		if [ $# -gt 2 ]; then	
			section=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}
			# echo "$HOME"
			# echo "$full_path"
			# echo "$docker_path"
			echo "🐪 execute in container $INSTANCE ..."
			if docker restart $INSTANCE > /dev/null; then				
				docker exec -i $INSTANCE sh -c "cd $docker_path ;\
				 python $section"
			fi
		fi
	;;

	"micros" )
		container_name="python-micros"
		if container_procs.py -c $container_name exists > /dev/null; then
			echo "$container_name ok ..."
		else
			# initiaize this container and install dependencies
			docker volume create --name python3.root
			docker run -d --net=dev-net --name $container_name \
				-p 3000:3000 \
				-p 5000:5000 \
			 	-v python3.root:/root \
				-v $HOME/works/rust/practice/macros.linux/target/release/macros:/app/macros \
			  	$IMAGE /app/macros

			# install libraries
			docker exec -i $container_name sh -c "apt-get update"
			pip install redis flask
		fi

		if [ $# -gt 2 ]; then	
			section=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}

			echo "$container_name starting ..."
			if docker restart $container_name > /dev/null; then				
				docker exec -i $INSTANCE sh -c "cd $docker_path ;\
				 python $section"
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

	* ) 
		echo "available options: new, init, repl, repl.local, install.local, deps, help" 
		echo "unknown: " $*
	;;
esac
