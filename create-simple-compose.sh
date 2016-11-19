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
    networks:
      - back-tier

  rest:
    build: 
      context: ./rest
      dockerfile: run.dockerfile
    ports:
      - "8080:8080"
    depends_on:
      - redis
    networks:
      - back-tier
      - dev-net

  bash:
    image: nile/dev
    networks:
      - back-tier
      - dev-net

  redis:
    image: redis
    ports:
      - "6379:6379"
    networks:
      - back-tier
  
  #############
  
  #############

volumes:
  db-data:

networks:
  dev-net:
  	external: true
  # front-tier:
  back-tier:      
  	external: true
EOF

echo "$cnt"> docker-compose.yml
echo "done."
