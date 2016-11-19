#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

SPARK_HOME=/works/spark/spark-2.0/spark-2.0.0-bin-hadoop2.7
CMD=$1
case "$CMD" in
	"local.shell")		
		echo "
		  steps: ~/works/scala/scripts/spark/basic_ops.scala
		  type :quit to quit.
		"		
		$SPARK_HOME/bin/spark-shell
		;;

	"local.submit")
		cd ~/works/scala/scripts/spark/simple
		echo "build package ..."
		sbt package

		echo "submit ..."
		$SPARK_HOME/bin/spark-submit \
		  --class "SimpleApp" \
		  --master local[4] \
		  target/scala-2.11/simple-project_2.11-1.0.jar


		;;
	"install")
		# 
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
