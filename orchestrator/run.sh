#!/bin/bash
set -euo pipefail

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

BLUE_SYM=${BLUE_GROUP: -1}
GREEN_SYM=${GREEN_GROUP: -1}

echo "green is $GREEN_GROUP, blue is $BLUE_GROUP"

## IN BLUE GROUP: create instance and invoke ecs service
echo "BLUE instance 0 -> 1"
aws autoscaling set-desired-capacity --auto-scaling-group-name $BLUE_GROUP --desired-capacity 1
echo "BLUE service 0 -> 1"
GROUP_NAME=$BLUE_SYM ecspresso --config="$PWD/ecspresso/ecspresso.yml" scale --tasks=1

## IN GREEN GROUP: stop ecs service and shutdown instance
echo "GREEN service 1 -> 0"
GROUP_NAME=$GREEN_SYM ecspresso --config="$PWD/ecspresso/ecspresso.yml" scale --tasks=0
echo "GREEN instance 1 -> 0"
aws autoscaling set-desired-capacity --auto-scaling-group-name $GREEN_GROUP --desired-capacity 0
