#!/bin/bash
# aws iam create-user --user-name geoportalp

# aws s3api create-bucket --bucket "geoportalp-files" --create-bucket-configuration LocationConstraint="us-east-2" --acl "public-read"

# aws s3api put-bucket-cors --bucket "geoportalp-files" --cors-configuration file://cors.json

# aws iam create-policy --policy-name geoportalp --policy-document file://api-access-policy.json

# aws iam attach-user-policy --policy-arn "arn:aws:iam::052280825519:policy/geoportalp" --user-name "geoportalp"

# TODO: create compute environment, job queues and job definitions
