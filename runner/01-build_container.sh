# docker run -it perl:5.36.0-slim-bullseye /bin/bash
# docker run -p 5000:5000 -it test /bin/bash

# aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_ENDPOINT

VERSION=`date "+%Y%m%d_%H%M%S"`
BASE="$(dirname $(realpath $0))"
cd "$BASE/../docker"

docker build . -t "$DOCKER_CONTAINER_IMAGE_NAME:$VERSION"

docker tag "$DOCKER_CONTAINER_IMAGE_NAME:latest" "$ECR_ENDPOINT/$DOCKER_CONTAINER_IMAGE_NAME:$VERSION"

docker push "$ECR_ENDPOINT/$DOCKER_CONTAINER_IMAGE_NAME:$VERSION"
