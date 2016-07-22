#!/bin/bash
if [ $# -lt 1 ]; then	
	echo "assign a project name"
	exit -1
fi

CMD=$1
case "$CMD" in
	"run")		
		mvn package exec:java
		;;
	"call")
		curl -i http://localhost:8080/myapp/myresource
		echo ""
		;;
	*)
		project=$CMD
		mvn archetype:generate -DarchetypeArtifactId=jersey-quickstart-grizzly2 \
			-DarchetypeGroupId=org.glassfish.jersey.archetypes -DinteractiveMode=false \
			-DgroupId=nile.micros -DartifactId=$project -Dpackage=nile.micros \
			-DarchetypeVersion=2.23.1
		;;
esac
