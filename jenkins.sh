#!/usr/bin/env bash
docker run -d --net=dev-net --name jenkins \
	-p 8080:8080 -p 50000:50000 \
	-v $HOME/srv/jenkins:/var/jenkins_home --user=root jenkins

# ref: https://hub.docker.com/_/jenkins/
