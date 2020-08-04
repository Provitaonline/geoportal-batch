#!/bin/bash
# aws iam create-user --user-name geoportalp

# aws s3api create-bucket --bucket "geoportalp-files" --create-bucket-configuration LocationConstraint="us-east-2" --acl "public-read"

# aws s3api put-bucket-cors --bucket "geoportalp-files" --cors-configuration file://cors.json

# aws iam create-policy --policy-name geoportalp --policy-document file://api-access-policy.json

# aws iam attach-user-policy --policy-arn "arn:aws:iam::052280825519:policy/geoportalp" --user-name "geoportalp"

# TODO: create roles: AWSBatchServiceRole & ecsInstanceRole (and attach policies)

# Create AWSBatchServiceRole and ecsInstanceRole
# aws iam create-role --role-name AWSBatchServiceRole --assume-role-policy-document file://batch-role-trust-policy.json
# aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole --role-name AWSBatchServiceRole
# aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole --role-name AWSBatchServiceRole
# aws iam create-role --role-name ecsInstanceRole --assume-role-policy-document file://ecs-role-trust-policy.json
# aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole --role-name ecsInstanceRole
# aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role --role-name ecsInstanceRole

# Grab default vpc
defaultvpc=$(aws ec2 describe-vpcs --filter Name="is-default",Values="true" | jq '.Vpcs | .[0] | .VpcId')

# Get subnets assiciated with default vpc
subnets=$(aws ec2 describe-subnets --filter Name="vpc-id",Values=$defaultvpc | jq '{subnets: [.Subnets[] | .SubnetId]}')

# Get default securiy group for default vpc
securitygroups=$(aws ec2 describe-security-groups --filter Name="vpc-id",Values=$defaultvpc Name="group-name",Values="default" | jq ".SecurityGroups[] | select(.VpcId==$defaultvpc) | [.GroupId]")

echo $subnets
echo $defaultvpc
echo $securitygroups

#cat compute-environment.json | jq ". + {computeResources: $subnets} + {computeResources: {securityGroupIds: $securitygroups}}"

cat compute-environment.json | jq ".computeResources += $subnets | .computeResources += {securityGroupIds: $securitygroups}" > compute-environment-updated.json

# aws batch create-compute-environment --cli-input-json file://compute-environment-updated.json

# Create container repos
#aws ecr create-repository --repository-name geoportalp-rtiles
#aws ecr create-repository --repository-name geoportalp-vtiles

# Push container images
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 052280825519.dkr.ecr.us-east-2.amazonaws.com

# docker build -t geoportalp-rtiles ../rtiles
# docker build -t geoportalp-vtiles ../vtiles

# docker tag geoportalp-rtiles:latest 052280825519.dkr.ecr.us-east-2.amazonaws.com/geoportalp-rtiles:latest
# docker tag geoportalp-vtiles:latest 052280825519.dkr.ecr.us-east-2.amazonaws.com/geoportalp-vtiles:latest

docker push 052280825519.dkr.ecr.us-east-2.amazonaws.com/geoportalp-rtiles:latest
docker push 052280825519.dkr.ecr.us-east-2.amazonaws.com/geoportalp-vtiles:latest

# TODO: create job queues and job definitions
