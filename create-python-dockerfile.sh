#!/bin/bash

parent=${PWD##*/}

if [ -f "Dockerfile" ]; then
	echo "exists, exit."
	exit 0
fi

read -d '' cnt <<EOF
# Using official python runtime base image
FROM python:2.7

# Set the application directory
WORKDIR /app

# Install our requirements.txt
ADD requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Copy our code from the current folder to /app inside the container
ADD . /app

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost:8080/healthcheck || exit 1

# Make port 8080 available for links and/or publish
EXPOSE 8080 

# Define our command to be run when launching the container
CMD ["python", "app.py"]

EOF

echo "$cnt"> Dockerfile
echo "$cnt"> run.dockerfile

# requirements.txt
read -d '' cnt <<EOF
Flask
Redis
healthcheck
EOF

echo "$cnt"> requirements.txt

read -d '' cnt <<EOF
from flask import Flask
from healthcheck import HealthCheck, EnvironmentDump

# option_a = os.getenv('OPTION_A', "Cats")
app = Flask(__name__)

# https://github.com/Runscope/healthcheck
# wrap the flask app and give a heathcheck url
health = HealthCheck(app, "/healthcheck")
envdump = EnvironmentDump(app, "/environment")

if __name__ == "__main__":
	app.run(host='0.0.0.0', port=8080, debug=True)

EOF

echo "$cnt"> app.py

read -d '' cnt <<EOF
#!/bin/bash
curl "http://localhost:8080/healthcheck"
curl "http://localhost:8080/environment"
EOF

echo "$cnt"> visit.sh
chmod +x visit.sh

echo 'done.'
