#!/bin/bash 
 
        #############
        # Functions #
        #############
        
        #################
        # ignoreDigests #
        #################
        ignore_digest () {
        
           # Retrieve the stack id/name from the application image       
           STACK_NAME=$( skopeo inspect docker://$INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE  | jq -r '.Labels."dev.appsody.stack.id"' ) 
           # Retrieve the version from the application image
           STACK_VERSION=$( skopeo inspect docker://$INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE  | jq -r '.Labels."dev.appsody.stack.version"' ) 
           # Retrieve all the version of the stack
           CLUSTER_STACK_VERSIONS=$( kubectl get stack $STACK_NAME  -o json | jq -r '.status.versions[].version?' )
        
           for VERSION in ${CLUSTER_STACK_VERSIONS}; do            
              # If the stack version starts with same pattern, we are done
              if [[ "$VERSION" == "$STACK_VERSION" ]]; then
                 echo "$INFO The application stack '$STACK_NAME', version: $STACK_VERSION is active and passes stackPolicy enforcement."
                 exit 0  
              fi  
           done          
        
           echo "$ERROR The application stack '$STACK_NAME', version: $STACK_VERSION is not active and fails stackPolicy enforcement."
           exit 0  

        }
        
        ################################
        # activeDigests & strictDigest #
        ################################
        active_strict_digest () {
 
           # Retrieve the stack id/name from the application image       
           STACK_NAME=$( skopeo inspect docker://$INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE  | jq -r '.Labels."dev.appsody.stack.id"' ) 
           # Retrieve the version from the application image
           STACK_VERSION=$( skopeo inspect docker://$INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE  | jq -r '.Labels."dev.appsody.stack.version"' ) 
           # Retrieve the version from the application image
           STACK_DIGEST=$( skopeo inspect docker://$INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE  | jq -r '.Labels."dev.appsody.stack.digest"' ) 
           # TODO: Temporary until Appsody is able to correctly set this label
           if [ -z "$STACK_DIGEST" ] || [ "$STACK_DIGEST" == "null" ]; then\
              echo "$WARNING The image label 'dev.appsody.stack.digest' has not been set for image: $INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE, unable to enforce stackPolicy"
              exit 0  
           fi
           # Retrieve all the digests of the stack
           CLUSTER_STACK_DIGESTS=$( kubectl get stack $STACK_NAME -o json | jq -r '.status.versions[].images[].digest.activation?' )
        
           for DIGEST in ${CLUSTER_STACK_DIGESTS}; do            
              # If the stack version starts with same pattern, we are done
              if [[ "sha256:$DIGEST" == "$STACK_DIGEST" ]]; then
                 echo "$INFO The application stack '$STACK_NAME', version: $STACK_VERSION is active and passes stackPolicy enforcement."
                 exit 0  
              fi  
              echo "$INFO $DIGEST : $STACK_DIGEST"
           done          
           echo "$ERROR The application stack '$STACK_NAME', version: $STACK_VERSION is not active and fails stackPolicy enforcement."
           exit 0  

        }
        
        
        #### MAIN ###
        
        INFO="[INFO]"
        WARNING="[WARNING]"
        ERROR="[ERROR]"
         
        #Setting insecure image registries
        #executing the insecure_registry_setup.sh script if exists, to add user mentioned registry url to insecure registry list
        if [ -f "/workspace/$gitsource/insecure_registry_setup.sh" ]; then
           echo "$INFO Running the script /workspace/$gitsource/insecure_registry_setup.sh ...."
           /workspace/$gitsource/insecure_registry_setup.sh
        fi

        #Making tls-verify=true for the image registries based on additional trusted ca certs provided by the user.
        #executing the ca_certs_setup.sh script if exists, to add additional trusted ca certs to /etc/docker/certs.d/<hosname>/ca.crt
        if [ -f "/workspace/$gitsource/ca_certs_setup.sh" ]; then
           echo "$INFO Running the script /workspace/$gitsource/ca_certs_setup.sh ...."
           /workspace/$gitsource/ca_certs_setup.sh
        fi
        
        # env var gitsource
        GITSOURCE=$gitsource
        INPUTS_RESOURCE_DOCKER_IMAGE_URL_LOWERCASE=$1

        # Get stack policy
        # Values: strictDigest, activeDigest (default if blank), ignoreDigest and none
        # https://github.com/kabanero-io/kabanero-foundation/blob/master/design/digest.md

        STACK_POLICY=$( kubectl get kabanero kabanero -o json | jq -r '.spec.governancePolicy.stackPolicy' )
        # Default to value "activeDigest" - if the CR lacks a value, the default is to be used
        if [ -z "$STACK_POLICY" ] || [ "$STACK_POLICY" == "null" ]; then
           STACK_POLICY="activeDigest"
        fi
        if [ "$STACK_POLICY" == "none" ]; then
           echo "$INFO stackPolicy' under 'governancePolicy' is set to 'none', skipping stackPolicy validation."
           exit 0
        fi
        echo "$INFO Enforcing 'stackPolicy' of '$STACK_POLICY'."
        if [ "$STACK_POLICY" == "strictDigest" ] || [ "$STACK_POLICY" == "activeDigest" ]; then
           active_strict_digest
        fi   
        
        if [ "$STACK_POLICY" == "ignoreDigest" ]; then
           ignore_digest
        fi    
        echo "$ERROR Unrecognized stackPolicy specified: '$STACK_POLICY'."     
        exit 1