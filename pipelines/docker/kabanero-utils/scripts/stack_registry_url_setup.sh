#!/bin/sh
# This script fetch the stack registry url from '.appsody-config.yaml' from the git-source stack project and determines correct registry url for the stack to be pulled from , 
# it has 3 conditions
#  1. If the stack url does not have any registry url then it assumes the url is 'docker.io', and returns as output of this script.
#  2. If the stack url has openshift internal image registry external route, then it uses internal registry internal route 'image-registry.openshift-image-registry.svc:5000', and returns as output of this script.
#  3. If first 2 cases are not true, it returns the registry url it finds as output of this script.


        APPSODY_CONFIG=".appsody-config.yaml"
            
        # Default the stack registry to docker.io
        STACK_IMAGE_REGISTRY_URL="docker.io"

        cd /workspace/$gitsource
            
        if [ ! -f "$APPSODY_CONFIG" ]; then
           echo "$APPSODY_CONFIG is not found in the root of the source directory."
           exit 1
        else
           # Find the value for "stack:" from the appsody config file and assign it to the variable 'stack'
           declare $( awk '{if ($1 ~ "stack:"){printf "STACK="$2}}'  $APPSODY_CONFIG )
           if [ -z "$STACK" ]; then
              echo "$APPSODY_CONFIG does not contain a stack definition."
              exit 1
           fi
        fi

        # The stack registry may or may not be in the appsody-cfg.yaml file
        # If it's there the format should be like registry/project/name:version
        # It could also just be project/name:version.
        # Try to determine if the registry is there and if it is, parse it out
        NUM_SLASHES=$(awk -F"/" '{print NF-1}' <<< "${STACK}")
        if [ "$NUM_SLASHES" = 1 ]; then
           STACK_IMAGE_REGISTRY_URL="docker.io"
        elif [ "$NUM_SLASHES" = 2 ]; then
           STACK_IMAGE_REGISTRY_URL="$(echo $STACK | cut -d'/' -f1)"
        else
           echo "Unexpected format for stack in APPSODY_CONFIG. Using docker.io as the stack registry"
           exit 1
        fi
        
        #Logic to convert external to internal route of internal registry
        external_route_internal_registry=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.externalRegistryHostnames[0]}")
        if [[ ! -z "$external_route_internal_registry" ]]; then
            if [[ $external_route_internal_registry == $STACK_IMAGE_REGISTRY_URL ]]
            then
               internal_route_internal_registry=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.internalRegistryHostname}")
               if [[ ! -z "$internal_route_internal_registry" ]]; then
                  STACK_IMAGE_REGISTRY_URL=$internal_route_internal_registry
               else
                  echo "Error: Internal image registry is not found, and you are trying to use the internal image registry external route as your stack registry."
                  echo "Hint : kubectl get image.config.openshift.io/cluster -o yaml --output=\"jsonpath={.status.internalRegistryHostname}\" "
                  exit 1
               fi
            fi
        fi
        echo "$STACK_IMAGE_REGISTRY_URL"

