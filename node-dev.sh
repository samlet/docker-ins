#!/bin/bash
docker start node-dev

# local x
if [ $# -lt 1 ]; then	
	docker attach node-dev
else
	#let cmd="$*"
	echo "exec in new shell -> " $*
	docker exec -it node-dev bash
fi

