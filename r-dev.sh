#!/usr/bin/env bash

# docker run --rm -it r-base

INSTANCE=r-dev
docker start $INSTANCE

# local x
if [ $# -lt 1 ]; then	
	docker exec -it $INSTANCE bash	
else	
	echo "exec in new shell -> " $*
	docker exec -it $INSTANCE $*
fi

# exec REPL: $ r-dev.sh R
