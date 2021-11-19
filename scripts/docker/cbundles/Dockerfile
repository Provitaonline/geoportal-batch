# Use amazonlinux docker image
FROM amazonlinux:latest

# Install dependencies
RUN yum -y install deltarpm
RUN yum -y install which aws-cli curl tar

# Install nodejs and aws sdk
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash
RUN yum -y install nodejs
RUN npm install aws-sdk

WORKDIR /tmp
COPY config.sh .
COPY docker/cbundles/build-tars.sh .
COPY docker/cbundles/targenscript.js .
