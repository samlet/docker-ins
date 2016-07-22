#!/bin/bash

# set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

INSTANCE=ofbiz-inst
PORT=${PORT:-8080}
IMAGE=${IMAGE:-"nile/java-dev"}

java_root=$HOME/works/microservices/java
ofbiz_root=$java_root/ofbiz.14.12
entity_root=$ofbiz_root/framework/entity

EXEC="docker exec -it $INSTANCE"

switch_docker_profile(){
	cp $entity_root/config/entityengine.docker.xml \
		$entity_root/config/entityengine.xml
}

tag=nile/ofbiz:v1
incl_dir="$(dirname "$0")"
. $incl_dir/conf/sites.sh
dockerize(){
	echo "dockerize ofbiz image ..."
	# https://docs.docker.com/engine/tutorials/dockerimages/
	# rel_server="192.168.0.110"
	ofbiz_tag_url="http://$rel_server/releases/ofbiz.14.12-bin.tar.gz"
	echo "the ofbiz rel url: $ofbiz_tag_url"

	read -d '' dockerfile <<-EOF
	FROM java:8
	MAINTAINER Samlet Wu <xiaofei.wu@gmail.com>

	RUN set -xe && \
		echo "download package ..." && \
		curl -fSL "$ofbiz_tag_url" -o ofbiz.tar.gz && \
		mkdir -p /ofbiz && \
		tar -xvf ofbiz.tar.gz -C /ofbiz --strip-components=1 && \
		rm ofbiz.tar.gz

	WORKDIR /ofbiz
	CMD ["/ofbiz/ant", "start"]

	EXPOSE 8080 8443
	EOF

	echo "$dockerfile"
	echo "$dockerfile" > Dockerfile.tmp
	docker build -f Dockerfile.tmp -t $tag .	
}


CMD=$1
case "$CMD" in
	"s")		
		# docker volume ls -f dangling=true		
		docker start some-postgres
		switch_docker_profile

		# MICROS=${MICROS:-"ant start"}
		MICROS="java -Xms512M -Xmx1024M -XX:MaxPermSize=128m -jar ofbiz.jar"

		echo "run instance -> " $MICROS $PORT	

		docker run -it --rm --net=dev-net --name $INSTANCE \
			-v $HOME/works:/works \
			-v $ofbiz_root:/app \
			-p $PORT:8080 -p 8443:8443 \
			-v $HOME/caches/dev:/root \
			-w /app \
			$IMAGE $MICROS
		;;

	"s.local")
		docker start some-postgres

		cp $entity_root/config/entityengine.postgres.xml \
			$entity_root/config/entityengine.xml
		cd $ofbiz_root
		./ant start

		;;

	"s.docker")
		echo "now run ..."
		docker start some-postgres
		sleep 1
		docker run --rm --net=dev-net -it -p 8080:8080 -p 8443:8443 $tag

		;;

	"init")
		docker start some-postgres
		
		cp $entity_root/config/entityengine.postgres.xml \
			$entity_root/config/entityengine.xml
		cd $ofbiz_root
		./ant load-demo

		;;

	"shell")
		$EXEC bash

		;;

	"ecommerce")
		open "http://localhost:8080/ecommerce/"
		;;

	"order")
		open "https://localhost:8443/ordermgr"
		;;

	"admin")
		echo "You can log in with the user 'admin' and password 'ofbiz'."
		open "https://localhost:8443/webtools"
		;;

	"backup")
		if [ $# -gt 2 ]; then	
			echo "start backup ..."
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;

	"release")
		release_dir=$HOME/works/web/releases
		switch_docker_profile

		cd $java_root
		if [ -f $release_dir/ofbiz.14.12-bin.tar.gz ]; then
		    rm $release_dir/ofbiz.14.12-bin.tar.gz
		fi
		tar czf $release_dir/ofbiz.14.12-bin.tar.gz ofbiz.14.12

		# install procs:
		# OFBIZ_TGZ_URL=http://some-nginx/releases/ofbiz.14.12-bin.tar.gz
		# curl -fSL "$OFBIZ_TGZ_URL" -o ofbiz.tar.gz && \
		# 	tar -xvf ofbiz.tar.gz --strip-components=1
		;;

	"docker")
		if docker start some-nginx > /dev/null; then
			sleep 1
			dockerize
		fi
		;;

	*)
		# docker volume ls
		;;
esac


