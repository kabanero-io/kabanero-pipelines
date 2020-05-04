#!/bin/sh 
#This script has the logic to change docker-image resource url with image_name as lowercase.
# usage example 1: in usecases where input param 'docker-imagename=appsodyMPversion' and 'docker-imagetag=abcDEF' is present and 'docker-image' url= image-registry.openshift-image-registry.svc:5000/kabanero
#  Then output should be the url with docker-imagename 'appsodyMPversion' as lowercase, OutputURL = 'image-registry.openshift-image-registry.svc:5000/kabanero/appsodympversion:abcDEF'
# usage example 2: in jenkins case where input param 'docker-imagename' and 'docker-imagetag' are empty ,and if 'docker-image' url=docker.io/abcd, and if the 'app-deploy.yaml' file has 'name=java-MP-project' 
#  Then first the url is constructed from 'app-deploy.yaml' file from the github application project. Secondly the imagename in the url is converted to lowercase.
#  Output should be a constructed url and lowercase 'docker-imagename=java-mp-project', OutputURL = 'docker.io/abcd/java-mp-project' 

#Script Usage ./imageurl_imagename_lowercase.sh


display_help() {
 echo "Usage"
 echo "******************************************************"
 echo "./imageurl_imagename_lowercase.sh -u [docker regisrtry url] -n [docker imagename] -t [docker image tagname]"
 echo "example: "
 echo "./imageurl_imagename_lowercase.sh -u docker.io/<dockerid> -n nodejs-image -t latest" 
 echo "******************************************************"
 exit 1
}

while getopts ":hu:n:t:" opt; do
  case $opt in
	
    h)
     display_help  # Call your function
     exit 0
     ;;
    u)
      dockerimageUrl=$OPTARG
      ;;
    n)
      dockerimagename=$OPTARG
      ;;
    t)
      dockerimagetag=$OPTARG
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
done

docker_registry_url=$dockerimageUrl
docker_imagename=$dockerimagename
docker_imagetag=$dockerimagetag
app_deploy_filename="app-deploy.yaml"

if [[ -z "$docker_registry_url" ]]; then
   echo "Error : The input parameter docker-image resource url to the script is empty, please provide it and try again(Possible value example: docker.io/<docker-userid>, image-registry.openshift-image-registry.svc:5000/kabanero)"
   exit 1
else
   if [[ -z "$docker_imagename"  ]]; then
      if [[ -f /workspace/$gitsource/$app_deploy_filename ]];then
         cd /workspace/$gitsource
         APPNAME=$(awk '/^  name:/ {print $2; exit}' $app_deploy_filename)

         docker_imagename_lowercase=$(echo $APPNAME |  tr '[:upper:]' '[:lower:]')
      else
         echo "Error : docker_imagename is empty and the $app_deploy_filename is not present in the github appsody project.
         Either provide the value for the variable or make the $app_deploy_filename file available in the github appsody project
         Case 1: If you are running a pipeline where you do not want the docker imagename to be coming from 'app-deploy.yaml' ,
                 you would need to provide the imagename from the Trigger file.
                 (Hint: Check the pipeline trigger file passing the input parameter 'docker_imagename' to the pipelines)
         Case 2: If your requirement is to pull the imagename from the  'app-deploy.yaml' file variable 'name' , 
                 then you need to make sure that you have the file available in the appsody project in github whose url you have provided as git-source to the pipeline"
         exit 1                 
      fi
   else
      docker_imagename_lowercase=$(echo $docker_imagename |  tr '[:upper:]' '[:lower:]')
   fi
fi

#If it reaches here it means it has set the variable docker_imagename_lowercase correctly.
#Check if trailing '/' exists for docker registry url, it not add it.
if [[ $docker_registry_url != */ ]];then
   docker_registry_url=$docker_registry_url/
fi
        
#Concatenate docker_registry_url with the docker_imagename_lowercase and docker_imagetag(if exists)
if [[ ! -z "$docker_imagetag" ]]; then
   DOCKER_IMAGE_URL=$docker_registry_url$docker_imagename_lowercase:$docker_imagetag
else
   DOCKER_IMAGE_URL=$docker_registry_url$docker_imagename_lowercase
fi

echo "$DOCKER_IMAGE_URL"
