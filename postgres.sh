#!/bin/bash

set -e

INSTANCE=some-postgres



# local x
if [ $# -lt 1 ]; then	
	if docker start $INSTANCE > /dev/null; then
		docker exec -it $INSTANCE bash
	fi
else
	opt=$1
	USER=postgres
	case "${opt}" in
		"init" )
			## https://hub.docker.com/_/postgres/
			## https://github.com/sameersbn/docker-postgresql
			docker volume create --name postgres-volume
			# replace: -v $HOME/srv/postgres:/var/lib/postgresql/data
			docker run --name some-postgres --net=dev-net \
				-p 5432:5432 \
				-v $HOME/bin/docker-ins:/docker-ins \
				-v postgres-volume:/var/lib/postgresql/data \
				-e POSTGRES_PASSWORD=postgres -d postgres:9.5

		;;

		"transfer" )
			docker stop some-postgres

			docker volume create --name postgres-volume
			docker run --rm -it \
				-v $HOME/srv/postgres:/source \
				-v postgres-volume:/target \
				ubuntu bash -c "cp -r /source/* /target/"
			# cp -r /source/* /target/
		;;

	    "list" )
			if docker start $INSTANCE > /dev/null; then
		        docker exec -it $INSTANCE psql -U $USER -c "\l"
		    fi
	        
	    ;;

	    "create" )
			if [ $# -gt 1 ]; then
	        	echo "create database $2"
	        	SEQ="create database $2;"
	        	docker exec -it $INSTANCE psql -U $USER -c "$SEQ"
	        else
	        	echo "must assign database name"
	        fi
	        exit
	    ;;

	    "drop" )
			if [ $# -gt 1 ]; then
	        	echo "drop database $2"
	        	SEQ="drop database $2;"
	        	docker exec -it $INSTANCE psql -U $USER -c "$SEQ"
	        else
	        	echo "must assign database name"
	        fi
	        exit
	    ;;

	    "query" )
	        if [ $# -gt 2 ]; then
	        	echo "query $2.$3"
	        	SEQ="SELECT * FROM $3;"
	        	docker exec -it $INSTANCE psql -U $USER -d $2 -c "$SEQ"
	        else
	        	echo "must assign database name and table name"
	        fi
	        exit
	    ;;

	    "browse" )
			echo "open browser to query specific table."
		;;
	    
	    "export-xls" )
			echo "export table data to excel sheet."
		;;

	    "exit" )
	        exit
	    ;;

	    "repl" )
			#let cmd="$*"
			USER=postgres
			if [ $# -gt 1 ]; then
				USER=$2
			fi
			echo "exec in new shell with user -> " $*
			
			docker exec -it $INSTANCE psql -U $USER
		;;

	    * ) 
			echo "available options: create, init, repl" 
			echo "unknown: " $*
		;;
	esac

	
fi


