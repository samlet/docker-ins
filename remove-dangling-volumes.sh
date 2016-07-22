#!/bin/bash
docker volume rm $(docker volume ls -f dangling=true -q)

