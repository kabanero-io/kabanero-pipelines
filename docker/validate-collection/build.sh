#!/bin/bash

set -e

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker build -t $DOCKER_ORG/validate-collection -t $DOCKER_ORG/validate-collection:latest .
docker push $DOCKER_ORG/validate-collection