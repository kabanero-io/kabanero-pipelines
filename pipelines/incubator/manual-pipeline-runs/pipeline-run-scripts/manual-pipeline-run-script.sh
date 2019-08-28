#!/bin/bash

#set -Eeuox pipefail
set +x
set +v

display_help() {
 echo "Usage"
 echo "******************************************************"
 echo "./pipeline-manual-run.sh -r [git_repo of the test project] -i [docker registery path of the image] -c [collections name of which pipeline to be run]"
 echo "example: "
 echo "./pipeline-manual-run.sh -r https://github.com/aadeshpa/appsody-test-project -i index.docker.io/aadeshpa/my-java-microprofile-image -c java-microprofile"
 echo "******************************************************"
 exit 1
}
no_args="true"

while getopts ":hi:r:c:" opt; do
  case $opt in
	
    h)
     display_help  # Call your function
     exit 0
     ;;
    i)
      dockerImage=$OPTARG
      ;;
    r)
      appGitRepo=$OPTARG
      ;;
    c)
      collectionsName=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      display_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      display_help
      exit 1
      ;;
    *)
      display_help  
      ;;
  esac
  no_args="false"
done

if [[ "$no_args" == "true" ]]; then
   display_help
   exit 1
fi

### Configuration ###

# Docker image location given as input to the script.
DOCKER_IMAGE=$dockerImage

# Appsody project GitHub repository given as input to the script#
APP_REPO=$appGitRepo

PIPELINE_RESOURCE_FILE=https://raw.githubusercontent.com/kabanero-io/kabanero-pipelines/master/pipelines/incubator/manual-pipeline-runs/pipeline-resources-template.yaml
PIPELINE_RUN_MANUAL_FILE=https://raw.githubusercontent.com/kabanero-io/kabanero-pipelines/master/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-template.yaml

echo "Printing all the inputs"
echo "DOCKER_IMAGE=$DOCKER_IMAGE"
echo "APP_REPO=$APP_REPO"
echo "PIPELINE_RESOURCE_FILE=$PIPELINE_RESOURCE_FILE"
echo "PIPELINE_RUN_MANUAL_FILE=$PIPELINE_RUN_MANUAL_FILE"

### Tekton Example ###

# Namespace #
namespace=kabanero

# Pipeline Resources: Source repo and destination container image

curl -L ${PIPELINE_RESOURCE_FILE} \
  | sed "s|index.docker.io/<docker_id>/<docker_image_name>|${DOCKER_IMAGE}|" \
  | sed "s|https://github.com/<git_id>/<git_repo_name>|${APP_REPO}|" \
  | oc apply -n ${namespace} --filename -

# Manual Pipeline Run
curl -L ${PIPELINE_RUN_MANUAL_FILE} \
  | sed "s|<collection-name>|${collectionsName}|" \
  | oc apply -n ${namespace} --filename -
echo "done updating pipelinerun template"