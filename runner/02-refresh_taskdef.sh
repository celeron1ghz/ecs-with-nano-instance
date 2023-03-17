LATEST_ECR_DOCKER_IMAGE=`aws ecr list-images --repository-name $DOCKER_CONTAINER_IMAGE_NAME --query "imageIds[0].imageTag" --output text`
LATEST_TASKDEF_DOCKER_IMAGE=`aws ecs describe-task-definition --task-definition acceptessa2-test --query "taskDefinition.containerDefinitions[0].image" --output text | perl -ne 'print +(split ":")[1]'`

echo "ecr=$LATEST_ECR_DOCKER_IMAGE, taskdef=$LATEST_TASKDEF_DOCKER_IMAGE"

if [ $LATEST_ECR_DOCKER_IMAGE = $LATEST_TASKDEF_DOCKER_IMAGE ]; then
    echo "taskdef_container == ecr_container, so keep taskdef."
else
    export DOCKER_IMAGE_TAG=$LATEST_ECR_DOCKER_IMAGE

    echo "taskdef_container != ecr_container, so create taskdef."
    ecspresso --config=$ECSPRESSO_CONFIG_PATH register
fi