#!/usr/bin/env bash

# https://docs.docker.com/compose/django/

read -d '' composefile <<EOF
version: '2'
services:
  db:
    image: postgres
  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/code
    ports:
      - "8000:8000"
    depends_on:
      - db
EOF

read -d '' dockerfile <<EOF
FROM python:2.7
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/
EOF

read -d '' requirements <<EOF
Django
psycopg2
EOF


writeFile(){
  fileName=$1
  content=$2
  if [ -e $fileName ]; then
    echo "$fileName has already exists"
  else
    echo "$content" > $fileName
    echo "created $fileName."
  fi
}

writeFile "docker-compose.yml" "$composefile"
writeFile "Dockerfile" "$dockerfile"
writeFile "requirements.txt" "$requirements"

echo ""
echo "TODOs:"
echo "docker-compose build"
echo "docker-compose run web django-admin.py startproject composeexample ."
echo "docker-compose up"
echo "open http://0.0.0.0:8000/"

