#!/bin/sh 
#This script has the logic to change docker-image resource url with image_name as lowercase.
# usage example 1: in usecases where input param 'docker-imagename=appsodyMPversion' and 'docker-imagetag=abcDEF' is present and 'docker-image' url= image-registry.openshift-image-registry.svc:5000/kabanero
#  Then output should be the url with docker-imagename 'appsodyMPversion' as lowercase, OutputURL = 'image-registry.openshift-image-registry.svc:5000/kabanero/appsodympversion:abcDEF'
# usage example 2: in jenkins case where input param 'docker-imagename' and 'docker-imagetag' are empty ,and if 'docker-image' url=docker.io/abcd, and if the 'app-deploy.yaml' file has 'name=java-MP-project' 
#  Then first the url is constructed from 'app-deploy.yaml' file from the github application project. Secondly the imagename in the url is converted to lowercase.
#  Output should be a constructed url and lowercase 'docker-imagename=java-mp-project', OutputURL = 'docker.io/abcd/java-mp-project' 

#Script Usage ./imageurl_imagename_lowercase.sh


display_help() {
 echo "$INFO Usage"
 echo "$INFO ******************************************************"
 echo "$INFO ./imageurl_imagename_lowercase.sh -u [docker regisrtry url] -n [docker imagename] -t [docker image tagname]"
 echo "$INFO example: "
 echo "$INFO ./imageurl_imagename_lowercase.sh -u docker.io/<dockerid> -n nodejs-image -t latest" 
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

# Tracing prefixes
INFO="[INFO]"
WARNING="[WARNING]"
ERROR="[ERROR]"

if [[ ! -z "$docker_registry_url"  ]]; then
   docker_registry_url=${docker_registry_url%/}
   NUM_SLASHES=$(awk -F"/" '{print NF-1}' <<< "${docker_registry_url}")
   if [[ ("$NUM_SLASHES" -ge 2 ) && ( ! -z $docker_imagename ) && ($docker_imagename != "null")]]; then
      echo "$WARNING The image registry url=$docker_registry_url has imagename in it, and it is also provided as in input parameter=$docker_imagename to the pipeline as parameter,pipeline will use the imagename from $docker_registry_url."
      DOCKER_IMAGE_URL=$docker_registry_url
   else
      #Start of else
      if [[ ( -z "$docker_imagename") || ("$docker_imagename" == "null") ]]; then
         #Trim the trailing forward slash('/') and then count no of forward slash.
         if [[ $docker_registry_url == */ ]];then
            docker_registry_url=${docker_registry_url%/}
         fi
         NUM_SLASHES=$(awk -F"/" '{print NF-1}' <<< "${docker_registry_url}")
      
         # This case is to handle jenkins pipeline scenario, where the user would specify the image name in the app-deploy.yaml
         if [[ (-f /workspace/$gitsource/$app_deploy_filename) && ("$NUM_SLASHES" = 1) ]];then
            cd /workspace/$gitsource
            APPNAME=$(awk '/^  name:/ {print $2; exit}' $app_deploy_filename)
            docker_imagename_lowercase=$(echo $APPNAME |  tr '[:upper:]' '[:lower:]')
         else
            #Checking the migration case where imagename can be empty and if registry url has imagename. 
            #ex: image-registry.openshift-image-registry.svc:5000/kabanero/kab60-java-spring-boot2:e7a1448806240f0294035097c0203caa3f
            if [ "$NUM_SLASHES" = 1 ]; then
               echo "$ERROR image registry url=$docker_registry_url does not have imagename and tagname values, you can specify it in your pipeline resource or through trigger template and try again."
               exit 1
            elif [ "$NUM_SLASHES" = 2 ]; then
               url_imagename_tagname_Part=$(echo $docker_registry_url | rev | cut -d"/" -f1 | rev)
               if [[ ( ! -z $url_imagename_tagname_Part ) && ( $url_imagename_tagname_Part == *":"* ) ]]; then 
                  imagename=$(cut -d ':' -f 1 <<< "$url_imagename_tagname_Part" )
                  docker_imagename_lowercase=$(echo $imagename |  tr '[:upper:]' '[:lower:]')
                  docker_imagetag=$(cut -d ':' -f 2- <<< "$url_imagename_tagname_Part" )
               elif [[ (! -z $url_imagename_tagname_Part) ]]; then
                  imagename=$url_imagename_tagname_Part
                  docker_imagename_lowercase=$(echo $imagename |  tr '[:upper:]' '[:lower:]')
               else
                  echo "$ERROR docker_registry_url=$docker_registry_url does not have the imagename and the param docker_imagename is not specified. Please provide docker_registry_url with imagename or provide correct values for incoming params docker_imagename=$docker_imagename and try again. "
                  exit 1
               fi
               docker_registry_url=$(echo $docker_registry_url | rev | cut -d"/" -f2- | rev)
            fi   
         fi
         
      elif [[ ! -z "$docker_imagename" ]]; then
              docker_imagename_lowercase=$(echo $docker_imagename |  tr '[:upper:]' '[:lower:]')
      fi
      
      #If it reaches here it means it has set the variable docker_imagename_lowercase correctly.
      # If docker_registry_url value does not have trailing '/' add it before concatenating it with imagename
      if [[ $docker_registry_url != */ ]];then
         docker_registry_url=$docker_registry_url/
      fi
        
      #Concatenate docker_registry_url with the docker_imagename_lowercase and docker_imagetag(if exists)
      if [[ (! -z "$docker_imagetag") && ("$docker_imagetag" != "null") ]]; then
         DOCKER_IMAGE_URL=$docker_registry_url$docker_imagename_lowercase:$docker_imagetag
      else
         DOCKER_IMAGE_URL=$docker_registry_url$docker_imagename_lowercase
      fi
 
      #End of else
   fi
else
   echo "$ERROR Incoming image registry url is empty , please specify the image registry url in your webhook setup or event mediator or your pipeline resource and try again.
   [Hint] : The image registry url can be docker.io/<docker-userid> ex: image-registry.openshift-image-registry.svc:5000/kabanero"
   exit 1
fi

echo "$DOCKER_IMAGE_URL"