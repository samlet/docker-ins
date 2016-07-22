#!/bin/bash
## https://hub.docker.com/_/couchbase/

## port, net, name, volume
docker run --net=dev-net --name some-couchbase \
	-p 8091:8091 \
	-v $HOME/srv/couchbase:/opt/couchbase/var \
	-d couchbase:4.1.1

