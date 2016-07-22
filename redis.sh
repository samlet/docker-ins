#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-redis"}
IMAGE=${IMAGE:-"redis:3.2"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# redis container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		docker run --net=dev-net --name some-redis \
			-p 6379:6379 \
			-d redis:3.2

		# docker run --name some-redis \
		# 	-v $HOME/srv/redis:/data \
		# 	-d redis redis-server --appendonly yes 

	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC redis-cli
		fi
	;;

	"tests.node" )
		# https://github.com/NodeRedis/node_redis
		if docker start $INSTANCE > /dev/null; then
			export NODE_PATH=$HOME/works/shell/node_modules
			node <<-END
			var redis = require("redis"),
			    client = redis.createClient();

			// if you'd like to select database 3, instead of 0 (default), call
			// client.select(3, function() { /* ... */ });

			client.on("error", function (err) {
			    console.log("Error " + err);
			});

			client.set("string key", "string val", redis.print);
			client.hset("hash key", "hashtest 1", "some value", redis.print);
			client.hset(["hash key", "hashtest 2", "some other value"], redis.print);
			client.hkeys("hash key", function (err, replies) {
			    console.log(replies.length + " replies:");
			    replies.forEach(function (reply, i) {
			        console.log("    " + i + ": " + reply);
			    });
			    client.quit();
			});
			END
		fi
	;;

	"tests.python" )
		source $HOME/works/python/v3/myenv/bin/activate
		# https://pypi.python.org/pypi/redis
		if docker start $INSTANCE > /dev/null; then
			python <<-END
			import redis
			r = redis.StrictRedis(host='localhost', port=6379, db=0)
			r.set('foo', 'bar')
			print("get from redis: "+str(r.get('foo')))
			END
		fi

	;;

	* ) 
		echo "available options: new, init" 
		echo "unknown: " $*
	;;
esac
