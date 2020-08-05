#!/bin/bash
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
while [[ "$n" != "q" ]]; do

  echo
  echo "***********************************************"
  echo
  echo "Setup AWS environment to support geoportalp"
  echo "Using AWS account: $AWS_ACCOUNT"
  echo
  echo "***********************************************"
  echo
  echo "Select setup option below:"
  echo
  echo "  1) Create API user, S3 bucket, create and attach policies"
  echo "  2) Create compute environment and container repos"
  echo "  3) Push container images"
  echo "  4) Create job queues and job definitions"
  echo "  5) Do all of the above in sequence"
  echo "  q) Quit (no changes)"
  echo

  read n

  if [[ $n == 1 || $n == 5 ]]; then
    echo "Create API user"
    # aws iam create-user --user-name geoportalp

    echo "Create S3 bucket"
    # aws s3api create-bucket --bucket "geoportalp-files" --create-bucket-configuration LocationConstraint="us-east-2" --acl "public-read"
    # aws s3api put-bucket-cors --bucket "geoportalp-files" --cors-configuration file://cors.json

    echo "Create and attach API user access policy"
    # aws iam create-policy --policy-name geoportalp --policy-document file://api-access-policy.json
    # aws iam attach-user-policy --policy-arn "arn:aws:iam::$AWS_ACCOUNT:policy/geoportalp" --user-name "geoportalp"

    echo "Create AWSBatchServiceRole and ecsInstanceRole"
    # aws iam create-role --role-name AWSBatchServiceRole --assume-role-policy-document file://batch-role-trust-policy.json
    # aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole --role-name AWSBatchServiceRole
    # aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole --role-name AWSBatchServiceRole
    # aws iam create-role --role-name ecsInstanceRole --assume-role-policy-document file://ecs-role-trust-policy.json
    # aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole --role-name ecsInstanceRole
    # aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role --role-name ecsInstanceRole

  fi
  if [[ $n == 2  ||  $n == 5 ]]; then
    echo "Create compute environment"
    # Grab default vpc
    defaultvpc=$(aws ec2 describe-vpcs --filter Name="is-default",Values="true" | jq '.Vpcs | .[0] | .VpcId')
    # Get subnets associated with default vpc
    subnets=$(aws ec2 describe-subnets --filter Name="vpc-id",Values=$defaultvpc | jq '{subnets: [.Subnets[] | .SubnetId]}')
    # Get default securiy group for default vpc
    securitygroups=$(aws ec2 describe-security-groups --filter Name="vpc-id",Values=$defaultvpc Name="group-name",Values="default" | jq ".SecurityGroups[] | select(.VpcId==$defaultvpc) | [.GroupId]")

    cat compute-environment.json | jq ".computeResources += $subnets |
      .computeResources += {securityGroupIds: $securitygroups} |
      .computeResources += {spotIamFleetRole: \"arn:aws:iam::$AWS_ACCOUNT:role/aws-ec2-spot-fleet-role\"} |
      .serviceRole += \"arn:aws:iam::$AWS_ACCOUNT:role/AWSBatchServiceRole\"" > compute-environment-updated.json

    # aws batch create-compute-environment --cli-input-json file://compute-environment-updated.json

    echo "Create container repos"
    #aws ecr create-repository --repository-name geoportalp-rtiles
    #aws ecr create-repository --repository-name geoportalp-vtiles

  fi
  if [[ $n == 3  ||  $n == 5 ]]; then
    echo "Build and tag container images"
    region=$(aws configure get region)
    aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.$region.amazonaws.com
    # docker build -t geoportalp-rtiles ../rtiles
    # docker build -t geoportalp-vtiles ../vtiles

    # docker tag geoportalp-rtiles:latest $AWS_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/geoportalp-rtiles:latest
    # docker tag geoportalp-vtiles:latest $AWS_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/geoportalp-vtiles:latest
    echo "Push container images"
    # docker push $AWS_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/geoportalp-rtiles:latest
    # docker push $AWS_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/geoportalp-vtiles:latest
  fi
  if [[ $n == 4  ||  $n == 5 ]]; then
    echo "Create job queues"
    #aws batch create-job-queue --job-queue-name geoportalp-rtiles --priority 1 --compute-environment-order order=1,computeEnvironment=arn:aws:batch:us-east-2:$AWS_ACCOUNT:compute-environment/geoportalp-spot
    #aws batch create-job-queue --job-queue-name geoportalp-vtiles --priority 1 --compute-environment-order order=1,computeEnvironment=arn:aws:batch:us-east-2:$AWS_ACCOUNT:compute-environment/geoportalp-spot

    echo "Create job definitions"
    cat job-definition-rtiles.json | jq ".containerProperties += {image: \"$AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/geoportalp-rtiles\"} |
      .containerProperties += {jobRoleArn: \"arn:aws:iam::$AWS_ACCOUNT:role/ecsTaskExecutionRole\"}" > job-definition-rtiles-updated.json
    aws batch register-job-definition --cli-input-json file://job-definition-rtiles-updated.json

    cat job-definition-vtiles.json | jq ".containerProperties += {image: \"$AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/geoportalp-vtiles\"} |
      .containerProperties += {jobRoleArn: \"arn:aws:iam::$AWS_ACCOUNT:role/ecsTaskExecutionRole\"}" > job-definition-vtiles-updated.json
    aws batch register-job-definition --cli-input-json file://job-definition-vtiles-updated.json

  fi
  if [[ $n == 5 ]]; then
    break
  fi
done
echo "Done"
