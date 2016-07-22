#!/bin/bash

set -e

if [ $# -lt 1 ]; then	
	docker-machine ssh manager1 docker node ls
	exit 0
fi

incl_dir="$(dirname "$0")"
opt=$1
mirror_opts="--engine-registry-mirror=https://y5q5tgic.mirror.aliyuncs.com"

init_manager(){
	# https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/
	MANAGER1_IP=$(docker-machine ip manager1)
	docker-machine ssh manager1 docker \
		swarm init --auto-accept manager --auto-accept worker \
		--listen-addr $MANAGER1_IP:2377
}

join_workers(){
	MANAGER1_IP=$(docker-machine ip manager1)

	WORKER1_IP=$(docker-machine ip worker1)
	docker-machine ssh worker1 docker swarm join \
		--listen-addr $WORKER1_IP:2377 $MANAGER1_IP:2377
	WORKER2_IP=$(docker-machine ip worker2)
	docker-machine ssh worker2 docker swarm join \
		--listen-addr $WORKER2_IP:2377 $MANAGER1_IP:2377
}

join_manager(){
	MANAGER1_IP=$(docker-machine ip manager1)
	MANAGER2_IP=$(docker-machine ip manager2)
	docker-machine ssh manager2 docker swarm join --manager \
		--listen-addr $MANAGER2_IP:2377 $MANAGER1_IP:2377
}

case "${opt}" in
    "new" )
        
    ;;

    "init.manager" )
		docker-machine create $mirror_opts \
			--vmwarefusion-memory-size=2048 \
			-d vmwarefusion manager1

		init_manager

	;;

	"init.workers" )
		docker-machine create $mirror_opts \
			--vmwarefusion-memory-size=2048 \
			-d vmwarefusion worker1
		docker-machine create $mirror_opts \
			--vmwarefusion-memory-size=2048 \
			-d vmwarefusion worker2

		join_workers
	;;

	"join.workers" )
		join_workers
	;;

	"leave.workers" )
		WORKER=2
		for i in $(seq 1 $WORKER); do docker-machine ssh worker$i docker swarm leave; done		
	;;

	"drop.workers" )
		WORKER=2
		for i in $(seq 1 $WORKER); do docker-machine rm worker$i; done
	;;

	"add.manager" )
		docker-machine create $mirror_opts \
			--vmwarefusion-memory-size=1024 \
			-d vmwarefusion manager2

		join_manager
	;;

	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://docs.docker.com/engine/swarm/swarm-tutorial/"
		fi
	;;

	* ) 
		echo "available options: new, init.manager, init.workers, help" 
		echo "unknown: " $*
	;;
esac
