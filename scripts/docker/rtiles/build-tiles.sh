#!/bin/sh
# exit on error
set -e

baseurl="https://geoportalp-files.s3-us-east-2.amazonaws.com"

# Timestamp function
timestamp() {
  date
}

# Create color table file
echo $2 | sed "s/:/: /g" | tr "-" "\n" > color.txt

# Get source file
filename=$1
echo $(timestamp): "$baseurl/files/$filename"
curl -s -O $baseurl/files/$filename
name=${filename%.*}
namelc="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
echo $(timestamp): "derived name: $namelc"

# Generate tiles
echo $(timestamp): "create virtual raster with colors"
if [ $3 = "exact" ]; then EXACT="-exact_color_entry"; else EXACT=""; fi

gdaldem color-relief -alpha $EXACT -of vrt $filename color.txt temp.vrt

echo $(timestamp): "generate raster tiles"
gdal2tiles.py --profile=mercator -q -z 4-10 temp.vrt rtiles/bosques
echo -e "\n"

# Copy tiles to S3
echo $(timestamp): "remove old tiles from rtiles/$namelc"
aws s3 rm s3://geoportalp-files --quiet --recursive --exclude "*" --include "rtiles/$namelc*"
echo $(timestamp): "upload generated tiles to rtiles/$namelc"
aws s3 cp rtiles s3://geoportalp-files/rtiles --acl "public-read" --quiet --recursive
echo $(timestamp): "finished processing"