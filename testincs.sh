#!/bin/bash
incl_dir="$(dirname "$0")"
. $incl_dir/conf/sites.sh

ofbiz_tag_url="http://$rel_server/releases/ofbiz.14.12-bin.tar.gz"
echo "the ofbiz rel url: $ofbiz_tag_url"
