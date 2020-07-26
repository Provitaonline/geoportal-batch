# Use osgeo/gdal docker image
FROM osgeo/gdal:alpine-normal-latest

# Install dependencies
RUN apk update
RUN apk add aws-cli curl

WORKDIR /tmp
COPY build-tiles.sh .
