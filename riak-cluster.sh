#!/bin/bash
# riak cluster

set -e
cd $HOME/works/docker/riak/docker-riak

if [ $# -lt 1 ]; then	
	bin/start-local-cluster.sh
else
	CMD="$*"
	if [[ "${CMD}" == stop ]]; then		
		bin/stop-cluster.sh		
	elif [[ "${CMD}" == status ]]; then
		#statements
		bin/test-local.sh
	else
		echo "enter instance -> " $*	
		docker exec -it riak01 bash
	fi
fi

