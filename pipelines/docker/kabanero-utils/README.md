# kabanero-utils

This is an image based on base image 'appsody/appsody-buildah:0.6.0-buildah1.9.0' with utilities and tools installed that are used by Kabanero pipelines.

##Utilities installed
- kubectl
- jq
- skopeo


##Scripts included in the image

 - [image_registry_access_setup.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/image_registry_access_setup.sh)      
 
 - [enforce_stack_policy.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/enforce_stack_policy.sh)
 
 
 - [enforce_deploy_stack_policy.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/enforce_deploy_stack_policy.sh)
 
 
 - [imageurl_imagename_lowercase.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/imageurl_imagename_lowercase.sh)
 
 
 - [stack_registry_url_setup.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/stack_registry_url_setup.sh)
 
 
 - [install_utilities.sh](https://github.com/kabanero-io/kabanero-pipelines/blob/master/pipelines/docker/kabanero-utils/scripts/install_utilities.sh)
