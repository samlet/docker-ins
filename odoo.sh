#!/bin/bash
# refs: https://hub.docker.com/_/odoo/

if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

CMD=$1
case "$CMD" in
	"init")		
		docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo --name odoo-db postgres:9.4
		docker run -p 8069:8069 --name odoo --link odoo-db:db -t odoo		
		;;
	"restart")
		docker stop odoo
		docker start -a odoo
		echo ""
		;;
	"s")
		docker start odoo-db
		docker start -a odoo
		;;
	"upgrade")
		# By default, Odoo 8.0 uses a filestore (located at /var/lib/odoo/filestore/) 
		# for attachments. You should restore this filestore in your new Odoo instance 
		# by running
		docker run --volumes-from odoo -p 8070:8069 --name odoo-v2 --link odoo-db:db -t odoo
		;;
	*)
		# docker start -a odoo
		docker exec -u root -it odoo bash
		;;
esac
