#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"php-dev"}
IMAGE=${IMAGE:-"nile/dev"}
WORKDIR=${WORKDIR:-"/works/php"}

EXEC="docker exec -it $INSTANCE"

########################
# php container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

incl_dir="$(dirname "$0")"
docker_ins=$HOME/bin/docker-ins
ubuntu_container=$INSTANCE

opt=$1

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		# docker volume create --name elasticsearch-volume		
		docker run -it --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
		 	-v $HOME/caches/dev:/root \
		 	-v $docker_ins:/docker-ins \
			-w $WORKDIR \
		  	$IMAGE bash

		## contains: 
		##	inherits init-dev: build-essential, cmake, python
		## 	contains: curl, vim, nginx, php7.0-fpm, php
		##		'php -v' -> PHP 7.0.4-7ubuntu2 (cli) ( NTS )

		## 	apt-get -y install php7.0-mysql php7.0-curl php7.0-gd 
		## 		php7.0-intl php-pear php-imagick php7.0-imap 
		## 		php7.0-mcrypt php-memcache  php7.0-pspell 
		## 		php7.0-recode php7.0-sqlite3 php7.0-tidy 
		## 		php7.0-xmlrpc php7.0-xsl php7.0-mbstring php-gettext

		##	additional: php-apcu, php-redis

		## initialize steps:
		#	clear_env = no
		#
		#	[www]
		#	listen = [::]:9000
		#	
		#	append above lines to /etc/php/7.0/fpm/php-fpm.conf 

		## start line:
		# php-fpm7.0 -d variables_order="EGPCS" && \
		#	(tail -F /var/log/nginx/access.log &) && \
		#	exec nginx -c `pwd`/nginx-dev.conf -g "daemon off;"
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC redis-cli
		fi
	;;

	"deps" )
		if docker start $INSTANCE > /dev/null; then
			$EXEC opam depext -i cohttp lwt ssl
		fi
	;;

	"s" )
		docker start $INSTANCE
		docker logs -f $INSTANCE
	;;

	"stop" )
		docker stop $INSTANCE
	;;


	"c.init" )
		image="ubuntu:16.04"
		docker run --name=$ubuntu_container -it \
				--net=dev-net \
				-v $HOME/works:/works \
				-v $HOME/bin/docker-ins:/docker-ins \
				-v $HOME/works/ubuntu/xenial/in-docker.list:/etc/apt/sources.list \
				-w /works \
				$image bash
	;;

	"c.enter" )
		docker start -i $ubuntu_container
	;;

	"c.exec" )
		# exec redis_simple.php: $ php.sh c.exec redis_simple $(pwd)
		if [ $# -gt 2 ]; then	
			program=$2
			full_path=$3
			docker_path=${full_path/#${HOME}/}

			echo "execute $program.php ..."
			cmd="cd $docker_path ; \
				php $program.php
				"
			if docker restart $ubuntu_container > /dev/null; then
				docker exec -i $ubuntu_container sh -c "$cmd"
			fi
		fi
	;;

	"c.single" )
		if [ $# -gt 1 ]; then	
			program=$2
			container_name="go.$program"
			docker rm -f $container_name > /dev/null
			docker run -d \
				--name=$container_name \
				--net=dev-net \
				-v $(pwd):/app \
				-w /app \
				golang:1.7 sh -c "go build $program.go && \
					./$program \
				"
			docker logs -f $container_name
		fi
	;;
	
	"help" )
		if [ $# -gt 1 ]; then	
			section=$2
			echo "help $section"
		else
			open "https://hub.docker.com/_/erlang/"
		fi
	;;

	* ) 
		echo "available options: new, init, repl, deps, help" 
		echo "unknown: " $*
	;;
esac
