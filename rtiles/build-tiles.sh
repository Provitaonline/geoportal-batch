#!/bin/sh
# exit on error
set -e
# cd /tmp
filename=$1
echo "get https://geoportalp.s3-us-west-2.amazonaws.com/files/$filename"
curl -s -O https://geoportalp.s3-us-west-2.amazonaws.com/files/$filename
name=${filename%.*}
namelc="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
echo "derived name: $namelc"

echo "remove old tiles from vtiles/$namelc"
# aws s3 rm s3://geoportalp --dryrun --recursive --exclude "*" --include "vtiles/$namelc*"
echo "upload generated tiles to vtiles/$namelc"
# aws s3 cp vtiles s3://geoportalp/vtiles --acl "public-read" --content-encoding "gzip" --dryrun --recursive
