#!/bin/bash
docker start php-dev

# local x
if [ $# -lt 1 ]; then	
	docker attach php-dev
else
	#let cmd="$*"
	echo "exec in new shell -> " $*
	docker exec -it php-dev bash
fi

