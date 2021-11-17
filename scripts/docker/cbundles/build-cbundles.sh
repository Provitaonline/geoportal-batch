#!/bin/bash
# exit on error
set -e
source ./config.sh

baseurl="https://$BUCKET.s3-$REGION.amazonaws.com"

echo "generate collection bundles"
