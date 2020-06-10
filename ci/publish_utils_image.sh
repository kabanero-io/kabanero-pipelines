#!/bin/bash
set -e

# This script will verify and run if TRAVIS_TAG is present which is the case only when a new releasecut takes place.
# Also along with the TRAVIS_TAG value, it checks if the travis settings has env variables DOCKER_USERNAME and DOCKER_PASSWORD
# set, to get access to the dockerhub repository for pushing the image if built.
# The script will build and push the image with the Travis env variables as
# docker.io/$DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG

echo "[INFO] Executing the script /ci/publish_utils_image.sh for TRAVIS_TAG=$TRAVIS_TAG"
#echo "Env variable from within the script publishImageStatus=${publishImageStatus}"
if [ ! -z "$TRAVIS_TAG" ] && [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
   cd ./pipelines/docker/kabanero-utils/
   
   #echo "Running Docker build"  
   docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG .
   if [ $? == 0 ]; then
      echo "[INFO] Docker image $DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG was build successfully" 
      echo "[INFO] Pushing the image $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG_NAME to docker.io/$DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG "
      echo "$DOCKER_PASSWORD" | docker login -u $DOCKER_USERNAME --password-stdin
      docker push $DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG
      if [ $? == 0 ]; then
          echo "[INFO] The docker image $DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG was successfully pushed to docker.io/$DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG"     
      else
        echo "[ERROR] The docker push failed for this image docker.io/$DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG, please check the logs"
        exit 1
      fi    
   else
      echo "[ERROR] The docker image $DOCKER_USERNAME/$IMAGE_NAME:$TRAVIS_TAG build failed, please check the logs."
      exit 1
   fi
else
       echo "[INFO] This travis build is not for a tagged TRAVIS_TAG and its empty, hence skipping the build and publish of the image $DOCKER_USERNAME/$IMAGE_NAME"
fi