#!/bin/bash
## https://hub.docker.com/_/postgres/
## https://github.com/sameersbn/docker-postgresql
docker run --name some-postgres --net=dev-net \
	-p 5432:5432 \
	-v $HOME/srv/postgres:/var/lib/postgresql/data \
	-e POSTGRES_PASSWORD=postgres -d postgres:9.5

## $ docker exec -it some-postgres bash
## # psql -U postgres
## # SELECT 1;

# CREATE TABLE cities (name varchar(80),location point);
# INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
# select * from cities;

