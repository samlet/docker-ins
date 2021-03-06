#!/bin/bash

# set -e

INSTANCE=${INSTANCE:-"java-dev"}
IMAGE=${IMAGE:-"java:8"}
WORKDIR=${WORKDIR:-"/works/java"}

EXEC="docker exec -it $INSTANCE"

########################
# java container
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
			-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		 	$IMAGE bash
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
			echo "compile and run ${section}.java"
			javac -cp .:deps.jar ${section}.java
			java -cp .:deps.jar $section
		fi
	;;

	"run.stub" )		
		topdir=$HOME/works/java/practice
		if [ $# -gt 1 ]; then	
			echo "kill old process ..."
			kill `jps | grep Launcher | cut -f1 -d" "`  > /dev/null 2>&1

			section=$2
			echo "compile and run ${section}.java with maven ..."
			cp ${section}.java $topdir/deps.maven/src/main/java/exec/Main.java
			cd $topdir/deps.maven
			mvn --quiet compile exec:java -Dexec.mainClass="exec.Main"
		fi
	;;

	"run.gradle" )		
		topdir=$HOME/works/java/practice
		if [ $# -gt 1 ]; then	
			echo "kill old process ..."
			kill `jps | grep GradleMain | cut -f1 -d" "`  > /dev/null 2>&1

			section=$2
			echo "compile and run ${section}.java with gradle ..."
			cp ${section}.java $topdir/deps.gradle/src/main/java/exec/Main.java
			cd $topdir/deps.gradle
			gradle run
		fi
	;;

	"run.kotlin" )		
		topdir=$HOME/works/kotlin/practice
		if [ $# -gt 1 ]; then	
			echo "kill old process ..."
			kill `jps | grep GradleMain | cut -f1 -d" "`  > /dev/null 2>&1

			section=$2
			echo "compile and run ${section}.kt with gradle ..."
			cp ${section}.kt $topdir/stub/src/main/kotlin/Main.kt
			cd $topdir/stub
			./gradlew run
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

	"create")
		if [ $# -gt 1 ]; then				
			section=$2
			echo "create project $section ..."
			mkdir $section
			cd $section
			gradle init --type java-library
			./gradlew build
		fi
	;;

	"create.docker")
		if [ $# -gt 1 ]; then				
			section=$2
			echo "create project $section ..."
			mkdir $section
			cd $section
			gradle init --type java-library
			create-java-dockerfile.sh
			./gradlew build
		fi
	;;

	"create.scala")
		if [ $# -gt 1 ]; then				
			section=$2
			echo "create project $section ..."
			mkdir $section
			cd $section
			gradle init --type scala-library
		fi		
	;;

	"create.compose")
		if [ $# -gt 1 ]; then				
			section=$2

			if [ -d "$section" ]; then
				echo "directory $section has exists."
			else
				echo "create docker-compose $section ..."
				cp -r ~/works/java/practice/micros-skel $section
				cd $section
				echo "done."
			fi
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
