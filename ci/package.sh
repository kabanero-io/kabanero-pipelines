#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'package' processing
exec_hooks $script_dir/ext/pre_package.d

pipelines_dir=$base_dir/pipelines/incubator
eventing_pipelines_dir=$base_dir/pipelines/incubator/events
gitops_pipelines_dir=$base_dir/pipelines/experimental/gitops

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
mkdir -p $assets_dir

image_original_string=kabanero/kabanero-utils:latest
DOCKER_KABANERO_ACCOUNT=kabanero

package() {
    local pipelines_dir=$1
    local prefix=$2
    echo -e "--- Creating pipeline artifacts for $prefix"
    # Generate a manifest.yaml file for each file in the tar.gz file
    asset_manifest=$pipelines_dir/manifest.yaml
    echo "contents:" > $asset_manifest

    # for each of the assets generate a sha256 and add it to the manifest.yaml
    assets_paths=$(find $pipelines_dir -mindepth 1 -maxdepth 1 -type f -name '*')
    local assets_names
    for asset_path in ${assets_paths}
    do
        asset_name=${asset_path#$pipelines_dir/}
        echo "Asset name: $asset_name"
        assets_names="${assets_names} ${asset_name}"
        if [ -f $asset_path ] && [ "$(basename -- $asset_path)" != "manifest.yaml" ]
        then
            sha256=$(cat $asset_path | $sha256cmd | awk '{print $1}')
            echo "- file: $asset_name" >> $asset_manifest
            echo "  sha256: $sha256" >> $asset_manifest
        fi
    done

    # build archive of tekton pipelines
    tar -czf $assets_dir/${prefix}-pipelines.tar.gz -C $pipelines_dir ${assets_names}
    tarballSHA=$(($sha256cmd $assets_dir/${prefix}-pipelines.tar.gz) | awk '{print $1}')
    echo ${tarballSHA}>> $assets_dir/${prefix}-pipelines-tar-gz-sha256
}

login_container_registry() {
    local container_registry_login_option=$1
    echo "[INFO] inside login_container_registry method Logging in the container registry using $container_registry_login_option "
    echo "$IMAGE_REGISTRY_PASSWORD" | $container_registry_login_option login -u $IMAGE_REGISTRY_USERNAME --password-stdin $IMAGE_REGISTRY
}
fetch_image_digest() {
   local destination_image_url=$1
   echo "Fetching the image digest value for image $destination_image_url"
   
   if [[ ( ! -z "$USE_BUILDAH" ) && ( "$USE_BUILDAH" == false ) ]]; then
      echo "[INFO] Fetching the image digest value for image $destination_image_url using docker inspect"
      docker pull $destination_image_url
      if [ $? != 0 ]; then
          echo "[ERROR] There is no such image with the image url = $destination_image_url hence the image could not be pulled to fetch the digest value, please verify the correct image url and try again."
          sleep 1
          exit 1
      fi
      image_digest_value_withquote=$(docker inspect --format='{{json .RepoDigests}}' $destination_image_url | jq 'values[0]');
      if [[ ( -z "$image_digest_value_withquote" ) ]]; then
         echo "[ERROR] The digest value for the image url : $destination_image_url could not be fetched using docker inspect. Please verify the image with the url exists and try again."
         sleep 1
         exit 1
      fi
      #This is to remove double quotes at the beginning and the end of the digest value found by above command
      image_digest_value=$(sed -e 's/^"//' -e 's/"$//' <<<"$image_digest_value_withquote");
      echo "[INFO] using docker inspect image_digest_value=$image_digest_value"
   elif [[ ( ! -z "$USE_BUILDAH" ) && ( "$USE_BUILDAH" == true ) ]]; then
      echo "[INFO] Fetching the image digest value for image $destination_image_url using skopeo inspect"
      image_digest_value_withquote=$( skopeo inspect docker://$destination_image_url | jq '.Digest' )
      if [[ ( -z "$image_digest_value_withquote" ) ]]; then
         echo "[ERROR] The digest value for the image url : $destination_image_url could not be fetched using skopeo inspect.Please verify the image with the url exists and try again"
         sleep 1
         exit 1
      fi
      image_digest_value=$(sed -e 's/^"//' -e 's/"$//' <<<"$image_digest_value_withquote");
      image_digest_value=$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$UTILS_IMAGE_NAME@$image_digest_value
      echo "[INFO] using skopeo image_digest_value=$image_digest_value"
   fi
   
   #calling method to replace the image digest value in all the yaml files.
   replace_image_url $image_digest_value
   
}
replace_image_url() {
   local image_digest_value=$1
   echo "[INFO] Replacing the utils container image string from 'image : $image_original_string' with 'image : $image_digest_value' in all the pipeline task yaml files";
   #cd ../../../
   echo "pwd"
   pwd
   echo "ls -ltr"
   ls -ltr
   ##echo "find all the files with yaml"
   ##find ./ -type f -name '*.yaml'
   
   echo "find and sed replace"
   if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "[INFO] The script is running in Mac OS"
      find ./ -type f -name '*.yaml' -exec sed -i '' 's|'"$image_original_string"'|'"$image_digest_value"'|g' {} +
   else
      echo "[INFO] The script is running in unix OS"
      find ./ -type f -name '*.yaml' -exec sed -i 's|'"$image_original_string"'|'"$image_digest_value"'|g' {} +
   fi
   #find ./ -type f -name '*.yaml' -exec sed -i 's|'"$image_original_string"'|'"$image_digest_value"'|g' {} +
   if [ $? == 0 ]; then
      echo "[INFO] Updated utils container image string from original 'image : $image_original_string' with 'image : $image_digest_value' in all the pipeline taks yaml files successfully"
   else
      echo "[ERROR] There was some error in updating the string from original 'image : $image_original_string' with 'image : $image_digest_value' in all the pipeline task yaml files."
      sleep 1
      exit 1
   fi
}
#Start
   
#setting the Utils image name as Default image name in case it is empty or not provided from env.sh
if [ -z "$UTILS_IMAGE_NAME" ]; then
   UTILS_IMAGE_NAME=$DEFAULT_IMAGE_NAME
fi
#setting up the utils image tagname as TRAVIS_TAG in case it is not empty, which is during Travis automation step.
# In other cases UTILS_IMAGE_TAG will be exported from env.sh file.
if [[ ( "$UTILS_IMAGE_REGISTRY_PUBLISH" == true ) && (! -z "$TRAVIS_TAG") ]]; then
   echo "Travis_tag variable is not empty TRAVIS_TAG=$TRAVIS_TAG"
   UTILS_IMAGE_TAG=$TRAVIS_TAG
fi
#setting default option to build image as docker. If you need to run the script with Buildah option, update USE_BUILDAH=true in env.sh
if [[ ( -z "$USE_BUILDAH" ) ]]; then
   USE_BUILDAH = false
fi
#preparing destination image url based on given inputs
if [[ (! -z "$IMAGE_REGISTRY") && ( ! -z "$IMAGE_REGISTRY_ORG" ) && ( ! -z "$UTILS_IMAGE_NAME" ) && ( ! -z "$UTILS_IMAGE_TAG" ) ]]; then
   echo "[INFO] Preparing destination utils image url using below variables as per given by the user"
   echo "[INFO] IMAGE_REGISTRY=$IMAGE_REGISTRY"
   echo "[INFO] IMAGE_REGISTRY_ORG=$IMAGE_REGISTRY_ORG"
   echo "[INFO] UTILS_IMAGE_NAME=$UTILS_IMAGE_NAME"
   echo "[INFO] UTILS_IMAGE_TAG=$UTILS_IMAGE_TAG"   
   destination_image_url=$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$UTILS_IMAGE_NAME:$UTILS_IMAGE_TAG
   echo "[INFO] Concatenated destination utils image urls are as below"
   echo "[INFO] destination_image_url=$destination_image_url" 
   destination_image_url_with_latest_tagname=$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$UTILS_IMAGE_NAME:latest
   echo "[INFO] destination_image_url_with_latest_tagname=$destination_image_url_with_latest_tagname" 
else
   echo "[ERROR] Image url cannot be formed ,one or more of the environment variables IMAGE_REGISTRY,IMAGE_REGISTRY_USERNAME, UTILS_IMAGE_NAME or UTILS_IMAGE_TAG are empty, please provide correct envrionment variables for image registry and image details for building the image and try again."
   echo "[ERROR] IMAGE_REGISTRY=$IMAGE_REGISTRY"
   echo "[ERROR] IMAGE_REGISTRY_ORG=$IMAGE_REGISTRY_ORG"
   echo "[ERROR] UTILS_IMAGE_NAME=$UTILS_IMAGE_NAME"
   echo "[ERROR] UTILS_IMAGE_TAG=$UTILS_IMAGE_TAG"
   sleep 1
   exit 1
fi
if [[ ( "$UTILS_IMAGE_REGISTRY_PUBLISH" == true ) ]]; then
   echo "[INFO] Publishing a new utils container image" 
   
   #Login to the registry if the username and password are present
   if [[ (! -z $IMAGE_REGISTRY) && (! -z "$IMAGE_REGISTRY_USERNAME") && (! -z "$IMAGE_REGISTRY_PASSWORD") ]]; then
      if [[ ( ! -z "$USE_BUILDAH" ) && ( "$USE_BUILDAH" == true ) ]]; then
         echo "[INFO] Logging in the container registry using buildah"
         login_container_registry "buildah"
      else
         echo "[INFO] Logging in to the container registry using docker"
         login_container_registry "docker"
      fi       
   fi
   # navigating to the folder where the utils container docker file is present
   cd ./pipelines/docker/kabanero-utils/              
   
   if [[ ( ! -z "$USE_BUILDAH" ) && ( "$USE_BUILDAH" == true ) ]]; then
   
      echo "[INFO] Building the utils container image using USE_BUILDAH=$USE_BUILDAH"
              
      buildah bud -t $destination_image_url -t $destination_image_url_with_latest_tagname .
      if [ $? == 0 ]; then
         echo "[INFO] The buildah container image $destination_image_url was build successfully"
                
         # Running actual buildah push command to push the image  to the registry using buildah.
         echo "[INFO] Pushing the image to $destination_image_url "
         buildah push $destination_image_url docker://$destination_image_url
         if [ $? == 0 ]; then
            echo "[INFO] The buildah container image $destination_image_url was successfully pushed"
            buildah push $destination_image_url_with_latest_tagname docker://$destination_image_url_with_latest_tagname     
         else
            echo "[ERROR] The buildah container image push failed for this image $destination_image_url, please check the logs"
            sleep 1
            exit 1
         fi    
      else
         echo "[ERROR] The buildah container image $destination_image_url build failed, please check the logs."
         sleep 1
         exit 1
      fi
        
      #navigating to the base folder     
      cd ../../../
        
      #calling method to fetch image digest value
      fetch_image_digest $destination_image_url          
   else
      echo "[INFO] Building the utils container image using USE_BUILDAH = $USE_BUILDAH"
      echo "[INFO] Running docker build for image url : $destination_image_url"
            
      # Running actual docker build command to build the image using docker.      
      docker build -t $destination_image_url -t $destination_image_url_with_latest_tagname .       
      if [ $? == 0 ]; then
         echo "[INFO] Docker image $destination_image_url was build successfully" 
         echo "[INFO] Pushing the image $destination_image_url "
               
         # Running actual docker push command to push the image  to the registry using docker.
         docker push $destination_image_url
         if [ $? == 0 ]; then
            echo "[INFO] The docker image was successfully pushed to $destination_image_url"
            docker push $destination_image_url_with_latest_tagname    
         else
            echo "[ERROR] The docker push failed for this image $destination_image_url, please check the logs"
            sleep 1
            exit 1
         fi    
      else
         echo "[ERROR] The docker image $destination_image_url build failed, please check the logs."
         sleep 1
         exit 1
      fi
      
      #navigating to the base folder      
      cd ../../../
      
      #calling method to fetch image digest value
      fetch_image_digest $destination_image_url
   fi  
else
   echo "[INFO] We are not publishing new utils container image since UTILS_IMAGE_REGISTRY_PUBLISH is not set to true "
   #calling method to fetch image digest value
   fetch_image_digest $destination_image_url
fi
#End

package $pipelines_dir "default-kabanero"

package $eventing_pipelines_dir "kabanero-events"

package $gitops_pipelines_dir "kabanero-gitops"

echo -e "--- Created pipeline artifacts"

# expose an extension point for running after main 'package' processing
exec_hooks $script_dir/ext/post_package.d

#echo -e "--- Building nginx container"
#ginx_arg=
#echo "BUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" > ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log
#if image_build ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log \
#    $nginx_arg \
#    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE \
##    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
#    -f $script_dir/nginx/Dockerfile $script_dir
#then
#    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE" >> $build_dir/image_list
#    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list
#    echo "created $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
#    trace "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
#else
#    stderr "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
#    stderr "failed building $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
#    exit 1
#fi
