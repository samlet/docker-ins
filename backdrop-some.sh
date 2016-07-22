#!/bin/bash
## ref: https://hub.docker.com/_/backdrop/
docker run --name some-backdrop -p 8080:80  \
	--net=dev-net \
	-e BACKDROP_DB_HOST=some-mysql \
	-e BACKDROP_DB_PORT=3306 \
	-e BACKDROP_DB_USER=root \
	-e BACKDROP_DB_PASSWORD=root \
	--link some-mysql:mysql -d backdrop


