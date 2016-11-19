#!/bin/bash
# set -e

if [ -f "docker-compose.yml" ]; then
	echo "exists docker-compose.yml, exit."
	exit 0
fi

mkdir rest simple

# parent=${PWD##*/}
read -d '' cnt <<-EOF
version: "2"

services:

  simple:
    build: 
      context: ./simple
      dockerfile: run.dockerfile
    links:
      - db
      - redis
    volumes_from:
      - bundle
    networks:
      - back-tier

  rest:
    build: 
      context: ./rest
      dockerfile: run.dockerfile
    ports:
      - "8080:8080"
    links:
      - redis
    volumes_from:
      - bundle
    networks:
      - back-tier 
      - dev-net

  # --- Add this to your fig.yml or docker-compose.yml file ---
  bundle:
    # 'image' will vary depending on your docker-compose 
    # project name. You may need to run "docker-compose build rest"
    # before this works.
    image: nile/java-dev
    command: echo "I'm a little data container, short and stout..."
    volumes:
      - /bundle

  visit:
    image: nile/dev
    command: curl http://rest:8080/base/helloworld
    depends_on:
      - rest
    networks:
      - back-tier

  bash:
    image: nile/dev
    volumes_from:
      - bundle
    networks:
      - back-tier

  redis:
    image: redis
    ports: ["6379"]
    networks:
      - back-tier

  db:
    image: postgres:9.5
    volumes:
      - "db-data:/var/lib/postgresql/data"
    networks:
      - back-tier  
  psql:
    image: postgres:9.5
    # link alias (SERVICE:ALIAS)
    links:
      - db:postgres
    entrypoint: ['psql', '-h', 'postgres', '-U', 'postgres']
    networks:
      - back-tier

volumes:
  db-data:

networks:
  dev-net:
    external: true
  # front-tier:
  back-tier:      
EOF

echo "$cnt"> docker-compose.yml
echo "done."
