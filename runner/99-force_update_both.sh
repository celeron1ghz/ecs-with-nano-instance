LATEST_ECR_DOCKER_IMAGE=`aws ecr list-images --repository-name $DOCKER_CONTAINER_IMAGE_NAME --query "imageIds[0].imageTag" --output text`

ASG_SYM="a" DOCKER_IMAGE_TAG=$LATEST_ECR_DOCKER_IMAGE ecspresso --config=$ECSPRESSO_CONFIG_PATH deploy
ASG_SYM="b" DOCKER_IMAGE_TAG=$LATEST_ECR_DOCKER_IMAGE ecspresso --config=$ECSPRESSO_CONFIG_PATH deploy