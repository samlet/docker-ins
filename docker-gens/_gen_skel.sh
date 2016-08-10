read -d '' composefile <<EOF
version: "2"

services:
  app:
    image: ruby:2.3
    command: ruby simple.rb
    volumes:
      - .:/app
    ports:
      - "5000:80"
    depends_on:
      - redis
    networks:
      - front-tier
      - back-tier

  redis:
    image: redis
    ports: ["6379"]
    networks:
      - back-tier

networks:
    front-tier:
    back-tier:
EOF

fileName=docker-compose.yml
if [ -e $fileName ]; then
  echo "$fileName has already exists"
else
  echo "$composefile" > $fileName
  echo "created."
fi

