#!/bin/bash

#set -Eeuox pipefail
set +x
set +v

oc > /dev/null 2>&1
if [ "$?" != "0" ]; then
   alias oc="kubectl"         
fi  

display_help() {
 echo "Usage"
 echo "******************************************************"
 echo "./manual-pipeline-run-script.sh -r [git_repo of the Appsody app project] -i [docker registery path of the image to be created] -c [stack name of which pipeline to be run]"
 echo "example: "
 echo "./manual-pipeline-run-script.sh -r https://github.com/<my-github-id>/appsody-test-project -i index.docker.io/<my-dockerhub-id>/my-java-microprofile-image -c java-microprofile"
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
      stackName=$OPTARG
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

PIPELINE_RESOURCE_FILE=pipeline-resources-template.yaml
CUSTOMIZED_PIPELINE_RESOURCE_FILE=${stackName}-${PIPELINE_RESOURCE_FILE}
pipeline_resource_dockerimage_template_text="docker.io/<docker_id>"
pipeline_resource_git_resource_template_text="https://github.com/<git_id>/<git_repo_name>"

PIPELINE_RUN_MANUAL_FILE=manual-pipeline-run-template.yaml
CUSTOMIZED_PIPELINE_RUN_MANUAL_FILE=${stackName}-${PIPELINE_RUN_MANUAL_FILE}
pipeline_run_stack_name_template_text="<stack-name>"

echo "Printing all the inputs"
echo "DOCKER_IMAGE=$DOCKER_IMAGE"
echo "APP_REPO=$APP_REPO"
echo "PIPELINE_RESOURCE_FILE=$PIPELINE_RESOURCE_FILE"
echo "PIPELINE_RUN_MANUAL_FILE=$PIPELINE_RUN_MANUAL_FILE"

### Tekton Example ###

# Namespace #
namespace=kabanero


# Pipeline Resources: Source repo and destination container image
cp -f ${PIPELINE_RESOURCE_FILE} ${CUSTOMIZED_PIPELINE_RESOURCE_FILE}
sed -i "s|${pipeline_resource_dockerimage_template_text}|${DOCKER_IMAGE}|g" ${CUSTOMIZED_PIPELINE_RESOURCE_FILE}
sed -i "s|${pipeline_resource_git_resource_template_text}|${APP_REPO}|g" ${CUSTOMIZED_PIPELINE_RESOURCE_FILE}
kubectl apply -n ${namespace} -f ${CUSTOMIZED_PIPELINE_RESOURCE_FILE}
rm -rf ${CUSTOMIZED_PIPELINE_RESOURCE_FILE}

# Manual Pipeline Run
cp -f ${PIPELINE_RUN_MANUAL_FILE} ${CUSTOMIZED_PIPELINE_RUN_MANUAL_FILE}
sed -i "s|${pipeline_run_stack_name_template_text}|${stackName}|g" ${CUSTOMIZED_PIPELINE_RUN_MANUAL_FILE}
kubectl apply -n ${namespace} -f ${CUSTOMIZED_PIPELINE_RUN_MANUAL_FILE}
rm -rf ${CUSTOMIZED_PIPELINE_RUN_MANUAL_FILE}

echo "done updating pipelinerun template"
