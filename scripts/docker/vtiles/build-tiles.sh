#!/bin/bash
# exit on error
set -e
source ./config.sh

baseurl="https://$BUCKET.s3-$REGION.amazonaws.com"

jobqueue="geoportalp-vtiles"
source ./check-running-jobs.sh

# cd /tmp
filename=$1
echo "get $baseurl/files/$filename"
curl -s -O $baseurl/files/$filename
name=${filename%.*}
namelc="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
echo "derived name: $namelc"
unzip -q -o $filename
echo "generate geojson for tippecanoe"
mapshaper -quiet -i $name/$name.shp -o format=geojson precision=0.0001 $namelc.geojson
echo "generate tiles"
mkdir -p vtiles
tippecanoe -q --force --layer=$namelc --name=$namelc --minimum-zoom=4 --maximum-zoom=10 --output-to-directory vtiles/$namelc $namelc.geojson
gzip vtiles/$namelc/metadata.json
mv vtiles/$namelc/metadata.json.gz vtiles/$namelc/metadata.json
echo "remove old tiles from vtiles/$namelc"
aws s3 rm s3://$BUCKET --quiet --recursive --exclude "*" --include "vtiles/$namelc*"
echo "upload generated tiles to vtiles/$namelc"
aws s3 cp vtiles s3://$BUCKET/vtiles --acl "public-read" --content-encoding "gzip" --quiet --recursive
