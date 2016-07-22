#!/bin/bash
## ref: https://github.com/mongo-express/mongo-express
docker run -it --rm --net=dev-net \
	--name mongo-express \
	-p 8081:8081 --link some-mongo:mongo \
	mongo-express
