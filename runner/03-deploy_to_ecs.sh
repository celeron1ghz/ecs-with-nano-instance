#!/bin/bash
set -euo pipefail

scaleout_asg() {
    ASG=$1
    SYM=${ASG: -1}

    LATEST_ECR_DOCKER_IMAGE=`aws ecr list-images --repository-name $DOCKER_IMAGE_NAME --query "imageIds[0].imageTag" --output text`

    export ASG_SYM=$SYM
    export DOCKER_IMAGE_TAG=$LATEST_ECR_DOCKER_IMAGE

    ## create instance and invoke ecs service
    echo "ASG($ASG) instance 0 -> 1"
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG --desired-capacity 1

    echo "ASG($ASG) service deploy"
    ecspresso --config=$ECSPRESSO_CONFIG_PATH deploy --latest-task-definition

    echo "ASG($ASG) service 0 -> 1"
    ecspresso --config=$ECSPRESSO_CONFIG_PATH scale --tasks=1
}

scalein_asg() {
    ASG=$1
    SYM=${ASG: -1}

    ## stop ecs service and shutdown instance
    echo "ASG($ASG) service 1 -> 0"
    ASG_SYM=$SYM ecspresso --config=$ECSPRESSO_CONFIG_PATH scale --tasks=0

    echo "ASG($ASG) instance 1 -> 0"
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG --desired-capacity 0
}

GROUP_A="acceptessa2-app-a"
GROUP_B="acceptessa2-app-b"

GROUP_A_COUNT=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $GROUP_A --query "length(AutoScalingGroups[0].Instances)"`
GROUP_B_COUNT=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $GROUP_B --query "length(AutoScalingGroups[0].Instances)"`

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

scaleout_asg $BLUE_GROUP

scalein_asg $GREEN_GROUP
