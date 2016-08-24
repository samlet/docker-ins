# subst
[ "$image" == "ubuntu" ] && image="ubuntu:16.04"
[ "$image" == "centos" ] && image="centos:7"
[ "$image" == "dev" ] && image="nile/dev"

[ "$image" == "gcc" ] && image="gcc:6.1"
[ "$image" == "ocaml" ] && image="ocaml/opam"
[ "$image" == "java" ] && image="java:8"
[ "$image" == "erlang" ] && image="erlang:19"
[ "$image" == "node" ] && image="node:6"
[ "$image" == "python" ] && image="python:3.5"
[ "$image" == "ruby" ] && image="ruby:2.3"
[ "$image" == "php" ] && image="php:7.0-alpine"
[ "$image" == "rust" ] && image="scorpil/rust:1.9"
# haskell:8
[ "$image" == "haskell" ] && image="haskell:8"
# nile/elixir:1.2
[ "$image" == "elixir" ] && image="nile/elixir:1.2"
# nile/go-dev
[ "$image" == "golang" ] && image="nile/go-dev"

[ "$image" == "tomcat" ] && image="tomcat:8.5"


[ "$image" == "mysql" ] && image="mysql:5.7"
[ "$image" == "postgres" ] && image="postgres:9.5"
#redis:3.2
[ "$image" == "redis" ] && image="redis:3.2"
