#!/bin/bash
## ref: https://hub.docker.com/_/nats/
## port, net, name, volume

# Run a NATS server
# Each server exposes multiple ports
# 4222 is for clients.
# 8222 is an HTTP management port for information reporting.
# 6222 is a routing port for clustering.

docker run --net=dev-net --name some-nats \
	-p 4222:4222 -p 8222:8222 -p 6222:6222 \
	-d nats:0.8.0

# To run a second server and cluster them together..
# $ docker run -d --name=nats-2 --link nats-main nats --routes=nats-route://ruser:T0pS3cr3t@nats-main:6222
