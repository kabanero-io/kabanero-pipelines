#!/bin/bash

set -e

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker build -t $DOCKER_ORG/ubi-kubectl -t $DOCKER_ORG/ubi-kubectl:latest .
docker push $DOCKER_ORG/ubi-kubectl
