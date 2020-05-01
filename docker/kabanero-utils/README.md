# kabanero-utils

This is an image based on base image 'appsody/appsody-buildah:0.6.0-buildah1.9.0' with utilities and tools installed that are used by Kabanero pipelines.

##Utilities installed
- kubectl
- jq
- skopeo


##Scripts included in the image

 - `insecure_registry_setup.sh`
 
This script is fetching the values of 'registries.insecure' from the 'image.config.openshift.io/cluster' resource that will be used by the tasks for setting the 'registries.insecure' in '/etc/containers/registries.conf' file of each step container in the pipelines. 
     
 
 - `ca_certs_setup.sh`
 
This script will be used in later tasks to fetch the trusted ca certificates configured
in a configmap which is set in the 'image.config.openshift.io/cluster' resource by the user, and we will copy the certificate values and generate 'ca.crt' as '/etc/docker/certs.d/<hostname>/ca.crt' for each certificate on the container.

 - `enforce_stack_policy.sh`
 
 - `enforce_deploy_stack_policy.sh`
 
 - `imageurl_imagename_lowercase.sh`
 
This script has the logic to change docker-image resource url with image_name as lowercase.

It has 2 usage scenarios:

  1: in usecases where input params 'docker-imagename=appsodyMPversion' and 'docker-imagetag=abcDEF' is present and the'docker-image' url= image-registry.openshift-image-registry.svc:5000/kabanero
  Then output should be the url with docker-imagename 'appsodyMPversion' as lowercase, OutputURL = 'image-registry.openshift-image-registry.svc:5000/kabanero/appsodympversion:abcDEF'
 
  2: in jenkins case where input param 'docker-imagename' and 'docker-imagetag' are empty ,and if 'docker-image' url=docker.io/abcd, and if the 'app-deploy.yaml' file has 'name=java-MP-project' 
  Then first the url is constructed from 'app-deploy.yaml' file from the github application project. Secondly the imagename in the url is converted to lowercase.
  Output should be a constructed url and lowercase 'docker-imagename=java-mp-project', OutputURL = 'docker.io/abcd/java-mp-project' 


 - `stack_registry_url_setup.sh`
 
This script fetch the stack registry url from '.appsody-config.yaml' from the git-source stack project and determines correct registry url for the stack to be pulled from , 
 
It has 3 conditions
  1. If the stack url does not have any registry url then it assumes the url is 'docker.io', and returns as output of this script.
  2. If the stack url has openshift internal image registry external route, then it uses internal registry internal route 'image-registry.openshift-image-registry.svc:5000', and returns as output of this script.
  3. If first 2 cases are not true, it returns the registry url it finds as output of this script.
 
 
 - `install_utilities.sh`
 
 This script install the tools required in the image kabanero-utils prepared by the Dockerfile, to be used in the pipelines.
