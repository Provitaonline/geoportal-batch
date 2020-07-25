# Use amazonlinux docker image
FROM amazonlinux:latest
# FROM lambgeo/lambda:gdal3.0

# Install dependencies
RUN yum -y install deltarpm
RUN yum -y install which unzip aws-cli git sqlite-devel curl
RUN yum -y groupinstall "Development Tools"

# Install nodejs
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash
RUN yum -y install nodejs

# Install mapshaper
RUN npm install -g mapshaper

# Install tippecanoe
RUN mkdir -p /tmp/tippecanoe-src
RUN git clone https://github.com/mapbox/tippecanoe.git /tmp/tippecanoe-src
WORKDIR /tmp/tippecanoe-src
RUN make -j && make install

# Remove the unneeded build files
RUN rm -rf /tmp/tippecanoe-src && yum -y groupremove "Development Tools"

WORKDIR /tmp
COPY build-tiles.sh .
