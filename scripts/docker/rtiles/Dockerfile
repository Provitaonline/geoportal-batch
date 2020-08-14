# Use osgeo/gdal docker image
FROM osgeo/gdal:ubuntu-small-latest

RUN apt-get -y install jq
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

WORKDIR /tmp
COPY config.sh .
COPY check-running-jobs.sh .
COPY docker/rtiles/build-tiles.sh .
