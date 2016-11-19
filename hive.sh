#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

CMD=$1

cd ~/works/docker/hive/docker-hive

case "$CMD" in
	"start")		
		docker-compose up -d namenode hive-metastore-postgresql
		sleep 1
		docker-compose up -d datanode hive-metastore
		sleep 1
		docker-compose up -d hive-server
		;;
	"hive.shell")
		# When starting the beeline client you will get the following error:
		# ls: cannot access /opt/hive/lib/hive-jdbc-*-standalone.jar: No such file or directory
		# This is a known bug in Hive 2.1.0 . It will be fixed in 2.1.1 and 2.2.0 releases. This error does not affect the connectivity to Hive.

		echo "
		  show tables;
		"

		docker exec -it hive-server bash -c "/opt/hive/bin/beeline -u jdbc:hive2://localhost:10000"

		;;
	"hive.bash")
		docker exec -it hive-server bash
		;;	
	"hadoop.bash")
		echo "type 'hadoop fs -ls /' to display root folder"
		docker exec -it namenode bash
		;;
	"ps")
		docker-compose ps
		;;

	"hadoop.ls")
		directory="/"
		if [ $# -gt 1 ]; then	
			directory=$2
		fi
		docker exec -it namenode hadoop fs -ls $directory
		;;

	"run")
		if [ $# -gt 1 ]; then	
			target=$2
			echo "run $target ..."
		else
			echo "use: ...."
		fi
		;;
	*)
		# docker volume ls
		;;
esac
