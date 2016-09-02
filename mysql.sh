#!/bin/bash

set -e


INSTANCE=${INSTANCE:-"some-mysql"}
IMAGE=${IMAGE:-"mysql:5.7"}
WORKDIR=${WORKDIR:-"/works"}

EXEC="docker exec -it $INSTANCE"

########################
# mysql container
########################

if [ $# -lt 1 ]; then	
	docker start $INSTANCE
	docker exec -it $INSTANCE bash
	exit 0
fi

opt=$1

node_root=$HOME/works/shell
volume_name=mysql-volume
export NODE_PATH=$node_root/node_modules

case "${opt}" in
    "new" )
        docker run -it --rm --net=dev-net \
        	-v $HOME/works:/works \
        	$IMAGE bash
        exit
    ;;

    "init" )
		## port, net, name, volume
		docker volume create --name $volume_name
		# file format: -v $HOME/srv/mysql:/var/lib/mysql
		docker run --net=dev-net --name some-mysql \
			-p 3306:3306 \
			-v $HOME/bin/docker-ins:/docker-ins \
			-v $volume_name:/var/lib/mysql \
			-e MYSQL_ROOT_PASSWORD=root -d mysql:5.7

		## $ docker exec -it some-mysql bash
		## # mysql -uroot -proot

	;;

	"transfer" )
		docker stop some-mysql

		docker volume create --name $volume_name
		docker run --rm -it \
			-v $HOME/srv/mysql:/source \
			-v $volume_name:/target \
			ubuntu bash -c "cp -r /source/* /target/"
		# cp -r /source/* /target/
	;;

	"repl" )
		if docker start $INSTANCE > /dev/null; then
			docker exec some-mysql mysqladmin --silent --wait=30 -uroot -proot ping || exit 1
			$EXEC mysql -uroot -proot
		fi
	;;

	"databases" )
		if docker start $INSTANCE > /dev/null; then
			echo "Waiting for DB to start up..."  
			docker exec some-mysql mysqladmin --silent --wait=30 -uroot -proot ping || exit 1
			$EXEC mysql -uroot -proot -e "show databases;"
		fi
	;;

	"create" )
		if [ $# -gt 1 ]; then
        	echo "create database $2"
        	SEQ="create database $2;"
        	$EXEC mysql -uroot -proot -e "$SEQ"
        fi
	;;

	"grant" )
		if [ $# -gt 2 ]; then
        	echo "grant database $2 to $3"
        	seq1="GRANT ALL ON $2.* to $3@'%' IDENTIFIED BY '$3';"
        	seq2="GRANT ALL ON $2.* to $3@localhost IDENTIFIED BY '$3';"
        	$EXEC mysql -uroot -proot -e "$seq1 $seq2"
        fi
	;;

	"demo.create.table" )
		if docker start $INSTANCE > /dev/null; then
			SEQ="CREATE TABLE t_user(
				id INT PRIMARY KEY AUTO_INCREMENT,
				name VARCHAR(16) NOT NULL ,
				create_date TIMESTAMP NULL DEFAULT now()
				)ENGINE=InnoDB DEFAULT CHARSET=utf8;
				CREATE UNIQUE INDEX t_quiz_IDX_0 on t_user(name);"
			$EXEC mysql -uroot -proot --database=test -e "$SEQ"
		fi
	;;

	"load" )
		if [ $# -gt 2 ]; then
			docker start some-mysql
			docker exec some-mysql mysqladmin --silent --wait=30 -uroot -proot ping || exit 1

			db=$2
			file=$3
			docker exec -i some-mysql mysql -uroot -proot $db < $file  
		else
			echo "syntax: - load <db> <file.sql>"
		fi
	;;

	"deps.node" )
		# https://github.com/mysqljs/mysql
		# http://blog.fens.me/nodejs-mysql-intro/
		cd $node_root
		npm install mysql
	;;

	"tests.node" )
		# https://github.com/mysqljs/mysql
		node <<-END
		var mysql      = require('mysql');
		var connection = mysql.createConnection({
		  host     : 'localhost',
		  user     : 'test',
		  password : 'test',
		  database : 'test'
		});

		connection.connect();

		connection.query('SELECT 1 + 1 AS solution', function(err, rows, fields) {
		  if (err) throw err;

		  console.log('The solution is: ', rows[0].solution);
		});

		connection.end();
		END

		# use pool
		node <<-END
		var mysql      = require('mysql');
		var pool  = mysql.createPool({
  		  connectionLimit : 10,
		  host     : 'localhost',
		  user     : 'root',
		  password : 'root',
		  database : 'employees'
		});

		pool.query('select title from titles limit 1', function(err, rows, fields) {
		  if (err) throw err;

		  console.log('The title is: ', rows[0].title);

		  // close pool, or else not end
		  pool.end( err => {
			  // all connections in the pool have ended
		  });
		});


		END
	;;

	* ) 
		echo "available options: new, init, repl" 
		echo "unknown: " $*
	;;
esac
