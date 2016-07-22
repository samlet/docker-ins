#!/bin/bash
INSANCE=elixir-1.2

docker start $INSANCE

# local x
if [ $# -lt 1 ]; then	
	docker attach $INSANCE
else
	#let cmd="$*"
	echo "exec in new shell -> " $*
	docker exec -it $INSANCE bash
fi

