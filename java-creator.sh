#!/usr/bin/env bash
set -e
PROJ_NAME=NONE
if [ $# -lt 1 ]; then	
	echo "assign a project name"
	exit -1
else
	PROJ_NAME=$1
fi

mkdir $PROJ_NAME
cd $PROJ_NAME
gradle init --type java-library
