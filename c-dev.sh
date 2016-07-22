#!/bin/bash
INSTANCE=c-dev
docker start $INSTANCE

# local x
if [ $# -lt 1 ]; then	
	docker attach $INSTANCE
else
	#let cmd="$*"
	echo "exec in new shell -> " $*
	docker exec -it $INSTANCE bash
fi

