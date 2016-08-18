#!/usr/bin/env bash

# https://docs.docker.com/compose/rails/

read -d '' composefile <<EOF
version: '2'
services:
  db:
    image: postgres
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/myapp
    ports:
      - "3000:3000"
    depends_on:
      - db
EOF

read -d '' dockerfile <<EOF
FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
EOF

read -d '' requirements <<EOF
source 'https://rubygems.org'
gem 'rails', '4.2.0'
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
writeFile "Gemfile" "$requirements"

## additional files
touch Gemfile.lock

echo ""
echo "TODOs:"

cat << EOF
  docker-compose run web rails new . --force --database=postgresql --skip-bundle

  Uncomment the line in your new Gemfile which loads therubyracer, so you’ve got a Javascript runtime:

  gem 'therubyracer', platforms: :ruby

  Replace the contents of config/database.yml with the following:

  development: &default
    adapter: postgresql
    encoding: unicode
    database: postgres
    pool: 5
    username: postgres
    password:
    host: db

  test:
    <<: *default
    database: myapp_test

EOF

echo "docker-compose build"
echo "docker-compose up"
echo "open http://0.0.0.0:3000/"

cat << EOF

Finally, you need to create the database. In another terminal, run:

  $ docker-compose run web rake db:create

EOF


