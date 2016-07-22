#!/bin/bash
# ofbiz-installer

# install procs, use enter.sh java 8080, then mkdir /ofbiz, enter /ofbiz
OFBIZ_TGZ_URL=http://some-nginx/releases/ofbiz.14.12-bin.tar.gz
curl -fSL "$OFBIZ_TGZ_URL" -o ofbiz.tar.gz
tar -xvf ofbiz.tar.gz --strip-components=1

