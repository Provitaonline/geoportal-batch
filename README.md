# Geoportal Provita AWS configuration files and scripts

This project is part of the source for Provita's Geographical Information Portal. These files are used to configure the AWS environment used to host datasets and pre-generated tiles.

## Development environment

The configuration script is written in ```bash```.

Tiles are generated using the AWS batch capability. Tile generation scripts are packaged as Docker images which are stored in the AWS Elastic Container Registry (ECR).

## Prerequisites

* ```bash```
* [docker](https://www.docker.com/)
* [aws cli](https://aws.amazon.com/cli/)

## Directory structure

```
scripts
  setupaws.sh (Main configuration script)
  *.json (aws cli configuration files)

rtiles
  build-tiles.sh (Raster tiles builder script)
  Dockerfile (Docker image generation script)

vtiles
  build-tiles.sh (Vector tiles builde script)
  Dockerfile (Docker image generation script)

```

## Deployment instructions

```
cd scripts
./setupaws.sh
```

The setup script provides a menu to configure/install aws requirements:

```
***********************************************

Setup AWS environment to support geoportalp
Using AWS account: 052280825519
Region: us-east-2

***********************************************

Select setup option below:

  1) Create API user, S3 bucket, create and attach policies
  2) Create compute environment
  3) Create container repos
  4) Push container images
  5) Create job queues and job definitions
  6) Do all of the above in sequence
  q) Quit (no changes)

```

## Licenses

The code is under [MIT license](https://opensource.org/licenses/MIT).
