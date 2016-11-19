#!/bin/bash
parent=${PWD##*/}

if [ -f "Dockerfile" ]; then
	echo "exists, exit."
	exit 0
fi

# build
read -d '' cnt <<EOF
FROM nile/php-nginx:7

# php7.0-bcmath, http://forums.fedoraforum.org/showthread.php?t=202413
RUN apt-get update -qq && apt-get install -y \
	php7.0-bcmath \
	&& apt-get clean

ADD www /www
EOF

echo "$cnt"> run.dockerfile

mkdir -p www

# index
cp /jcloud/php/template/index.php www/index.php

# worker
cp /jcloud/php/template/worker.php www/worker.php

# composer
read -d '' cnt <<EOF
{
    "require": {
        "torophp/torophp": "dev-master",
        "php-amqplib/php-amqplib": "v2.6.1"
    }
}
EOF

echo "$cnt"> www/composer.json

# https://getcomposer.org/doc/01-basic-usage.md
read -d '' cnt <<EOF
#!/bin/bash
composer.phar install
EOF

echo "$cnt"> www/deps.sh


