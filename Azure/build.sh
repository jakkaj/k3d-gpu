#!/bin/bash


#https://github.com/nvidia/k8s-device-plugin/

set -euxo pipefail

K3S_TAG=${K3S_TAG:="v1.23.3-k3s1"} # replace + with -, if needed
IMAGE_REGISTRY=${IMAGE_REGISTRY:="MY_REGISTRY"}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:="rancher/k3s"}
IMAGE_TAG="$K3S_TAG-cuda"
IMAGE=${IMAGE:="$IMAGE_REGISTRY/$IMAGE_REPOSITORY:$IMAGE_TAG"}


echo "IMAGE=$IMAGE"

# due to some unknown reason, copying symlinks fails with buildkit enabled
DOCKER_BUILDKIT=0 docker build \
  --build-arg K3S_TAG=$K3S_TAG \
  -t $IMAGE .
docker push $IMAGE
echo "Done!"



k3d cluster create gputest --image=$IMAGE --gpus=all --no-rollback 