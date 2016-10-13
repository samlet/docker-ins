#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command, available commands: init, install, run, ..."
	exit -1
fi

CMD=$1
case "$CMD" in
	"init")
		docker run --name mattermost -it --net=dev-net --publish 8066:8065 nile/go-dev /bin/bash
		;;
	"init.preview")		
		# https://docs.mattermost.com/install/docker-local-machine.html#one-line-docker-install

		# docker volume ls -f dangling=true		
		docker run --name mattermost-preview -d --publish 8065:8065 mattermost/mattermost-preview

		;;
	"open")
		open http://localhost:8065/ 
		;;	

	"remove.preview")
		docker stop mattermost-preview
		docker rm -v mattermost-preview
		;;

	"shell")		
		docker start mattermost
		docker exec -ti mattermost /bin/bash
		;;

	"shell.preview")
		docker exec -ti mattermost-preview /bin/bash
		;;

	"help")
		if [ $# -gt 1 ]; then	
			chapter=$2
			echo "about $chapter ..."
			case "$chapter" in
				"smtp")
					open https://docs.mattermost.com/install/docker-local-machine.html#recommended-enable-email
					;;
				"source")
					open https://github.com/mattermost/platform
					;;
				"production")
					open https://docs.mattermost.com/install/prod-docker.html
					;;

			esac
		else
			echo "use: ..."
		fi
		;;
	*)
		# docker volume ls
		;;
esac
