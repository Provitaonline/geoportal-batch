# Use amazonlinux docker image
FROM amazonlinux:latest

# Install dependencies
RUN yum -y install deltarpm
RUN yum -y install which unzip aws-cli git curl tar
RUN yum -y install jq

# Install nodejs
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash
RUN yum -y install nodejs

WORKDIR /tmp
COPY config.sh .
COPY docker/cbundles/build-cbundles.sh .
