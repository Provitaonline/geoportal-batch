#!/bin/bash
source ./config.sh
export BUCKET

echo 'retrieve file info from S3'

aws s3 ls s3://$BUCKET/files --recursive > files-list
aws s3 ls s3://$BUCKET/cbundles/tarfiles --recursive > cbundles-list
aws s3 cp s3://$BUCKET/cbundles/manifest.json . --only-show-errors

echo 'generate tar generation commands'
node targenscript.js

echo 'execute tar generation commands'
chmod +x ./do-tars.sh
./do-tars.sh

echo 'done'
