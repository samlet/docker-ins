#!/bin/bash
# stubs

if [ $# -lt 1 ]; then 
  echo "assign generator name, use: stubs.sh practice <.suffix>"
  exit -1
fi

# subst
incl_dir="$(dirname "$0")"

work_dir=$HOME/works
opt=$1
total_absents=0
total=0

gen(){
  # programming language constructive elements
  echo "generate $1 in $2"
  cd $2

  mkdir -p micros ffi
  # loader 用于指示在REPL上加载脚本
  for script in practice primitive_types basic flows strings regex_procs \
    buffers converters \
    collections comprehensions reflection_ops \
    pattern_matchings math_ops datetime_ops \
    functions functors objects modules loader typeof_ops \
    console_procs debugutils logger_procs \
    async net_procs processes \
    io_procs os_procs filesystems httpclients httpservices \
    databases json_procs xml_procs message_procs \
    cli_procs error_procs concurrent_procs ; do
    # echo "create $script"     
    fileName="$script$1"
    touch $fileName
    if [ -s $fileName ]; then 
      # only count file which line count grather than 5 line
      lines=`wc -l $fileName | awk '{print $1}'`
      if [ $lines -gt 5 ]; then
        echo "🐪 $fileName"
      else
        echo "🐨 $fileName"
        ((total_absents++))
      fi
    else
      echo "🐌 $fileName"
      ((total_absents++))
    fi
    ((total++))
  done
}

compose_dev(){
read -d '' composefile <<EOF
version: "2"

services:
  app:
    image: ubuntu:16.04
    command: bash -c "sleep 10"
    volumes:
      - .:/app
      - $HOME/works/ubuntu/xenial/in-docker.list:/etc/apt/sources.list
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
}

compose_ruby(){
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
}

write_batch(){
read -d '' cnt <<EOF
#!/usr/bin/env bash
echo "start ..."
EOF

  fileName=$1
  if [ -e $fileName ]; then
    echo "$fileName has already exists"
  else
    echo "$cnt" > $fileName
    echo "created."
  fi
}

write_readme(){
  header=$1
read -d '' cnt <<EOF
$header
================

EOF

  fileName=$2
  if [ -e $fileName ]; then
    echo "$fileName has already exists"
  else
    echo "$cnt" > $fileName
    echo "created."
  fi
}

case "${opt}" in
    "practice" )
    if [ -n "$2" ]; then
      gen $2 $(pwd)
    else
      echo "stubs practice <suffix>" # suffix: .erl
    fi    
    ;;

    "practice.all" )    
    gen ".java"   "$work_dir/java/practice" 
    gen ".scala"  "$work_dir/scala/scripts" 
    gen ".clj"    "$work_dir/clojure/practice" 

    gen ".ml"     "$work_dir/ocaml/practice" 
    gen ".hs"     "$work_dir/haskell/practice" 
    gen ".erl"    "$work_dir/erlang/practice"
    gen ".exs"    "$work_dir/erlang/practice_elixir"

    gen ".py"     "$work_dir/python/practice/v3" 
    gen ".rb"     "$work_dir/ruby/practice" 
    gen ".sh"     "$work_dir/shell/practice"    
    gen ".js"     "$work_dir/node.js/practice/basic"
    gen ".php"    "$work_dir/php/practice"    

    gen ".swift"  "$work_dir/swift/practice"
    gen ".rs"     "$work_dir/rust/practice"
    gen ".go"     "$work_dir/golang/practice"
    gen ".cc"     "$work_dir/cc/practice"
    gen ".c"      "$work_dir/c/practice"

    gen ".fs"     "$work_dir/dotnet/practice_fs" 
    gen ".cs"     "$work_dir/dotnet/practice" 

    # julia, r, scheme, common lisp, groovy

    echo ""
    echo "🐨 total absents: $total_absents / $total, 🐌 is absent file."
  ;;

  "db")
    cd ~/works
    for dbtype in hbase redis mongo riak cassandra postgres mysql ; do      
      for manage in crud_procs queries replications clusters seeders backups migrates stats business_models game_models social_models redis_broker rabbitmq_broker thrift_intf grpc_intf rest_intf websocket_intf socket_intf ; do
        folder=$dbtype/docker-ins/$manage
        echo "create folder $folder"
        mkdir -p $folder
        write_batch $folder/$manage.sh
      done

      write_readme "$dbtype" "$dbtype/docker-ins/README.md"
    done
  ;;

  "mq")
    cd ~/works
    for mqtype in rabbitmq redis kafka mqtt ejabberd ; do
      for manage in topic_procs queues rpc_brokers clusters ; do
        folder=$mqtype/docker-ins/$manage
        echo "create folder $folder"
        mkdir -p $folder
      done
    done
  ;;

  "world.base")
    cd ~/works
    # 实现ar-world, vr-world, ...等服务的基础技术演练, 比如实时通信及其通信协议, 大数据, 搜索, AI, 导航, NavMesh等等, 以server端技术为主, 并在前端分别以unity, ue4, h5方式呈现
    for interact in rabbitmq redis kafka netty mqtt lidgren raknet websocket ; do
      for manage in coordinators; do
        folder=$interact/docker-ins/$manage
        echo "create folder $folder"
        mkdir -p $folder
        write_batch $folder/$manage.sh
      done
    done

  ;;

  "compose")
    if [ -n "$2" ]; then
      argstart=3
      arginfo="${@:$argstart}"
      opt=$2
      case "$opt" in
        "dev")
          compose_dev $(pwd)
          docker-compose up
        ;;
        "ruby")
          compose_ruby $(pwd)
        ;;

        "django")
          exec bash $incl_dir/docker-gens/gen-django.sh $arginfo
        ;;
        "rails")
          exec bash $incl_dir/docker-gens/gen-rails.sh $arginfo
        ;;
        
        * )          
          echo "unknown option $opt $arginfo"
        ;;
      esac

    else
      echo "available prototypes: ruby, django, ..."
    fi
  ;;

  * )
    echo "unknown generator, available generators: practice"
  ;;
esac


