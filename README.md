# Geoportal Provita AWS configuration files and scripts

This project is part of the source for Provita's Geographical Information Portal. These files are used to configure the AWS environment used to host datasets and pre-generated tiles.

## Development environment

Shell scripts are written in ```bash```.

Tiles are generated using the AWS batch capability. Tile generation scripts are packaged as Docker images which are stored in the AWS Elastic Container Registry (ECR).

## Prerequisites

* ```bash```
* [docker](https://www.docker.com/)
* [aws cli](https://aws.amazon.com/cli/)
* [jq](https://stedolan.github.io/jq/)

## Directory structure

```
scripts

  config.sh (Config variables)
  setupaws.sh (Main configuration script)
  *.json (aws cli configuration files)

  docker

    cbundles
      build-tars.sh (Creates collection tar files by invoking targenscript.js, then do-tars.sh)
      Dockerfile (Docker image generation script)
      targenscript.js (Builds a script [do-tars.sh] that actually creates the tars)

    rtiles
      build-tiles.sh (Raster tiles builder script)
      Dockerfile (Docker image generation script)

    vtiles
      build-tiles.sh (Vector tiles builder script)
      Dockerfile (Docker image generation script)

```

## Deployment instructions

```
cd scripts
aws configure (enter AWS admin details)
./setupaws.sh
```

The setup script provides a menu to configure/install aws requirements:

```
***********************************************

Setup AWS environment to support geoportalp
Using AWS account: XXXXXXXXXX
Region: XX-XXXX-X

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
