#!/bin/bash
# docker start -i java-dev 
# docker attach java-dev

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

CMD=$1
case "$CMD" in
	"init")		
		docker volume create --name java.root		
		docker run -it --net=dev-net --name nile.java \
			 -v $HOME/works:/works \
			 -v java.root:/root \
			 -w /works/java/practice/jcloud \
			 nile/java-dev bash
		;;

	"bash")
		docker start nile.java		
		docker exec -it nile.java bash 
		;;	

	"run")
		if [ $# -gt 1 ]; then	
			target=$2
			echo "run $target ..."
		else
			echo "use: ...."
		fi
		;;
	*)
		# docker volume ls
		;;
esac

