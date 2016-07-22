#!/bin/bash
# php runner
set -e
INSTANCE=php-inst
if [ $# -lt 1 ]; then	
	docker rm php-inst
else
	INSTANCE="$*"
	echo "run instance -> " $*	
fi

docker run -it --net=dev-net --name $INSTANCE \
	-v $HOME/works:/works \
	-p 8000:80 \
	-v $HOME/caches/dev:/root \
	nile/php-dev /bin/bash

# then run start.sh in php source folder

