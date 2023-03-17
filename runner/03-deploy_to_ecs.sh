#!/bin/bash
set -euo pipefail

deploy_and_scaleup_asg() {
    ASG=$1
    SYM=${ASG: -1}

    ## create instance and invoke ecs service
    echo "ASG($ASG) instance 0 -> 1"
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG --desired-capacity 1
    echo "ASG($ASG) service 0 -> 1"
    ASG_SYM=$SYM DOCKER_IMAGE_NAME=$DOCKER_CONTAINER_IMAGE_NAME DOCKER_IMAGE_TAG=$LATEST_ECR_DOCKER_IMAGE ecspresso --config="$PWD/../ecspresso/ecspresso.yml" deploy --tasks=1
}

scaledown_asg() {
    ASG=$1
    SYM=${ASG: -1}

    ## stop ecs service and shutdown instance
    echo "ASG($ASG) service 1 -> 0"
    ASG_SYM=$SYM ecspresso --config="$PWD/../ecspresso/ecspresso.yml" scale --tasks=0
    echo "ASG($ASG) instance 1 -> 0"
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG --desired-capacity 0
}

GROUP_A="acceptessa2-app-a"
GROUP_B="acceptessa2-app-b"

GROUP_A_COUNT=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $GROUP_A --query "length(AutoScalingGroups[0].Instances)"`
GROUP_B_COUNT=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $GROUP_B --query "length(AutoScalingGroups[0].Instances)"`

LATEST_ECR_DOCKER_IMAGE=`aws ecr list-images --repository-name $DOCKER_CONTAINER_IMAGE_NAME --query "imageIds[0].imageTag" --output text`
LATEST_TASKDEF_DOCKER_IMAGE=`aws ecs describe-task-definition --task-definition acceptessa2-test --query "taskDefinition.containerDefinitions[0].image" --output text | perl -ne 'print +(split ":")[1]'`

if [ $GROUP_A_COUNT -ge 1 ] && [ $GROUP_B_COUNT -ge 1 ]; then
    echo "ERROR: both group instance are exist"
    exit 1
fi

if [ $GROUP_A_COUNT -eq 0 ] && [ $GROUP_B_COUNT -eq 0 ]; then
    echo "ERROR: both group instance are empty"
    exit 1
fi

if [ $GROUP_A_COUNT -ge 1 ]; then
    GREEN_GROUP=$GROUP_A
    BLUE_GROUP=$GROUP_B
else
    GREEN_GROUP=$GROUP_B
    BLUE_GROUP=$GROUP_A
fi

echo "green is $GREEN_GROUP, blue is $BLUE_GROUP"

deploy_and_scaleup_asg $BLUE_GROUP

scaledown_asg $GREEN_GROUP
