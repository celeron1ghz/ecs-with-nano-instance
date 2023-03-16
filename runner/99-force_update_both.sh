LATEST_DOCKER_IMAGE=`aws ecr list-images --repository-name $DOCKER_CONTAINER_IMAGE_NAME --query "imageIds[0].imageTag" --output text`

ASG_GROUP_SYM="a" DOCKER_IMAGE_NAME=$DOCKER_CONTAINER_IMAGE_NAME DOCKER_IMAGE_TAG=$LATEST_DOCKER_IMAGE ecspresso --config="$PWD/../ecspresso/ecspresso.yml" deploy
ASG_GROUP_SYM="b" DOCKER_IMAGE_NAME=$DOCKER_CONTAINER_IMAGE_NAME DOCKER_IMAGE_TAG=$LATEST_DOCKER_IMAGE ecspresso --config="$PWD/../ecspresso/ecspresso.yml" deploy