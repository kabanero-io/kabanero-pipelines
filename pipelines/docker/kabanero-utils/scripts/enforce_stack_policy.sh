#!/bin/bash 

        #############
        # Functions #
        #############
        
        #################
        # ignoreDigests #
        #################
        ignore_digest () {
        
           # If the version was "latest", sort all the installed versions to find the latest
           if [ "$VERSION" == "latest" ] && [ ! -z CLUSTER_STACK_VERSIONS ]; then
              echo 
              echo "$INFO The application stack, "$PROJECT/$STACK_NAME:$VERSION", in $APPSODY_CONFIG is active on this cluster and passes stackPolicy validation."
              exit 0  
           fi
           for STACK_VERSION in ${CLUSTER_STACK_VERSIONS}; do            
              # If the stack version starts with same pattern, we are done
              if [[ "$STACK_VERSION" == $VERSION* ]]; then
                 echo 
                 echo "$INFO The application stack, "$PROJECT/$STACK_NAME:$VERSION", in $APPSODY_CONFIG is active on this cluster and passes stackPolicy validation."
                 exit 0  
              fi  
           done  
           echo "$ERROR A compatible version of the application stack, "$PROJECT/$STACK_NAME:$VERSION", is not active on this cluster. Please review the active versions of the stack on the cluster (oc get stack $STACK_NAME -o json) and the stack specification in the $APPSODY_CONFIG file of the git project."
           echo "$ERROR Stack fails stackPolicy validation." 
           exit 1
        }
                
        #################
        # activeDigests #
        #################
        active_digest () {
 
           # Find matching versions
           for STACK_VERSION in ${CLUSTER_STACK_VERSIONS}
              do
                 if [[ "$STACK_VERSION" == $VERSION* ]]; then
                    CANDIDATE_STACK_VERSIONS+=$STACK_VERSION" "
                 fi
              done
           
           if [ -z "$CANDIDATE_STACK_VERSIONS" ]; then
              echo
              echo "$ERROR $APPSODY_CONFIG specifies a stack version of $VERSION , but there are no matching versions active. Versions active: $CLUSTER_STACK_VERSIONS"
              exit 1
           fi      
           
           # Check to see what enforcement phase we are in, if it's post-build, we can no longer patch the config, it's already been built
           if [ "$PHASE" == "post-build" ]; then
              echo "$ERROR Failed stackPolicy enforcement, application image has already been built, but the stack configuration in $APPSODY_CONFIG became invalid during the build phase."
              exit 1
           fi
           # Sort matching candidate versions
           SORTED_CLUSTER_STACK_VERSIONS=$( echo "$CANDIDATE_STACK_VERSIONS" | tr ' ' '\n' | sort | tr '\n' ' ' )
           # PATCH APPSODY-CONFIG
           LATEST=$( echo $SORTED_CLUSTER_STACK_VERSIONS | awk '{print $NF}' )
           PATCHED=${STACK//$VERSION/$LATEST}
           sed -i -e "s|$STACK|$PATCHED|g" $APPSODY_CONFIG
           echo "$WARNING $APPSODY_CONFIG, stack: value patched from '$STACK' to '$PATCHED' according to stackPolicy setting of 'activeDigest'"
           echo "$INFO The application stack, "$PROJECT/$STACK_NAME:$VERSION", in $APPSODY_CONFIG is active on this cluster and passes stackPolcy validation."
           exit 0
   
        }
        
        #################
        # strictDigests #
        #################
        strict_digest () {

           if [ "$STACK_POLICY" == "strictDigest" ]; then
              echo "$ERROR A compatible version of the application stack, "$PROJECT/$STACK_NAME:$VERSION", is not active on this cluster. Please review the active versions of the stack on the cluster (oc get stack $STACK_NAME -o json) and the stack specification in the $APPSODY_CONFIG file of the git project."
              exit 1
           else
              echo "$INFO The application stack, "$PROJECT/$STACK_NAME:$VERSION", in $APPSODY_CONFIG is active on this cluster and passes stackPolicy validation."
              exit 0
           fi 
        }
       
        ###  MAIN ###
       
        # Tracing prefixes
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
        PHASE=$1
        APPSODY_CONFIG=".appsody-config.yaml"

        # Get stack policy
        # Values: strictDigest, activeDigest (default if blank), ignoreDigest and none
        # https://github.com/kabanero-io/kabanero-foundation/blob/master/design/digest.md

        STACK_POLICY=$( kubectl get kabanero kabanero -o json | jq -r '.spec.governancePolicy.stackPolicy' )
        # Default to value "activeDigest" - if the CR lacks a value, the default is to be used
        if [ -z "$STACK_POLICY" ] || [ "$STACK_POLICY" == "null" ]; then
           STACK_POLICY="activeDigest"
        fi
        
        if [ "$STACK_POLICY" == "none" ]; then
           echo
           echo "$INFO stackPolicy' under 'governancePolicy' is set to 'none', skipping stack validation."
           exit 0
        fi
        echo
        echo "$INFO Enforcing 'stackPolicy' of '$STACK_POLICY'."
        echo

        cd /workspace/$GITSOURCE
        if [ ! -f "$APPSODY_CONFIG" ]; then
           echo "$ERROR $APPSODY_CONFIG is not found in the root of the source directory. Unable to do stackPolicy validation."
           exit 1
        fi
        

        ###################################################################################
        # Read project, stack image, docker host and stack name from .appsody-config.yaml #
        ###################################################################################
        echo
        echo "$INFO Read project, stack image, docker host and stack name from .appsody-config.yaml" 
        # Find the value for "stack:" from the appsody config file and assign it to the variable 'stack'
        declare $( awk '{if ($1 ~ "stack:"){printf "STACK="$2}}'  $APPSODY_CONFIG )
        if [ -z "$STACK" ]; then
           echo "$INFO $APPSODY_CONFIG does not contain a stack: definition. Unable to do stackPolicy validation."
           exit 1
        fi

        # Parse the image value for the repo, project, stackname and version
        # It can be in one of two formats based on appsody CLI used.
        # example 1: appsody/java-microprofile:0.2
        # example 2: image-registry.openshift-image-registry.svc:5000/kabanero/java-microprofile:0.2

        # For version get everything after last `:`
        VERSION="${STACK##*:}"
        echo "$INFO Git project config in $APPSODY_CONFIG... "
        echo "$INFO VERSION = $VERSION"

        # For project stack get everything before the last `:`
        PROJECT_STACK="${STACK%:*}"

        # The stack name could be after the 2nd or 3rd `/` based on appsody version. Check after 3rd first
        STACK_NAME="$(echo $PROJECT_STACK | cut -d'/' -f3 )"

        if [ -z "$STACK_NAME" ]; then
            PROJECT="$(echo $PROJECT_STACK | cut -d'/' -f1)"
            STACK_NAME="$( echo $PROJECT_STACK | cut -d'/' -f2 )"
        else
            STACK_REGISTRY="$(echo $PROJECT_STACK | cut -d'/' -f1)"
            PROJECT="$( echo $PROJECT_STACK | cut -d'/' -f2 )"
        fi

        echo "$INFO STACK_IMAGE_REGISTRY = $STACK_REGISTRY"
        echo "$INFO PROJECT = $PROJECT"
        echo "$INFO STACK_NAME = $STACK_NAME"

        # If the host wasn't specified, default to docker.io; if only specified in appsody-cfg.yaml use that
        if [ -z "$STACK_REGISTRY" ]; then
          IMAGE_REGISTRY_HOST="docker.io"
        else
          IMAGE_REGISTRY_HOST=$STACK_REGISTRY

          #Logic for if external route of internal image registry url given , then convert external to internal route of internal registry hostname
          external_route_internal_registry=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.externalRegistryHostnames[0]}")
          if [[ ! -z "$external_route_internal_registry" ]]; then
              if [[ $external_route_internal_registry == $IMAGE_REGISTRY_HOST ]]
              then
                 internal_route_internal_registry=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.internalRegistryHostname}")
                 if [[ ! -z "$internal_route_internal_registry" ]]; then
                    IMAGE_REGISTRY_HOST=$internal_route_internal_registry
                 else
                    echo "$ERROR Internal image registry is not found, and you are trying to use the internal image registry external route as your stack registry."
                    echo "Hint : kubectl get image.config.openshift.io/cluster -o yaml --output=\"jsonpath={.status.internalRegistryHostname}\" "
                    exit 1
                 fi
              fi
          fi
          echo "$INFO IMAGE_REGISTRY_HOST used finally = $IMAGE_REGISTRY_HOST"
        fi
        echo "$INFO Successfully read project, stack image, docker host and stack name from .appsody-config.yaml" 



        ########################################################################
        # Validate stack name & project are present, active in the Kabanero CR #
        ########################################################################
        echo
        echo "$INFO Validate stack name & project are present, active in the Kabanero CR"
        # Check to make sure the stack is active by name first
        kubectl get stack $STACK_NAME -o json > /dev/null 2>&1
        if [ $? -ne 0 ]; then
           echo "$ERROR No versions of $STACK_NAME in $APPSODY_CONFIG are active in the cluster.  Stack fails stackPolicy validation since $STACK_NAME is not active."
           echo "$ERROR Stack messages = $?"
           exit 1
        fi
        # Check if the project names in the cfg file and active stack match
        CLUSTER_STACK_IMAGE=$( kubectl get stack $STACK_NAME  -o json | jq -r '.status.versions[].images[].image?' )
        echo "$INFO In the cluster..."
        echo "$INFO STACK_IMAGE = $CLUSTER_STACK_IMAGE"
        # The stack name could be after the 2nd or 3rd `/` based on appsody version. Check after 3rd first
        THIRD_ENTRY="$(echo $CLUSTER_STACK_IMAGE | cut -d'/' -f3 )"
        if [ -z "$THIRD_ENTRY" ]; then
            CLUSTER_PROJECT="$(echo $CLUSTER_STACK_IMAGE | cut -d'/' -f1)"
            CLUSTER_STACK="$(echo $CLUSTER_STACK_IMAGE | cut -d'/' -f2)"
        else
            CLUSTER_STACK_REGISTRY="$(echo $CLUSTER_STACK_IMAGE | cut -d'/' -f1)"
            CLUSTER_PROJECT="$( echo $CLUSTER_STACK_IMAGE | cut -d'/' -f2 )"
            CLUSTER_STACK="$(echo $CLUSTER_STACK_IMAGE | cut -d'/' -f3)"
        fi
        echo "$INFO STACK_IMAGE_REGISTRY = $CLUSTER_STACK_REGISTRY"
        echo "$INFO PROJECT = $CLUSTER_PROJECT"
        echo "$INFO STACK_NAME = $CLUSTER_STACK"
        if [ "$CLUSTER_PROJECT" != "$PROJECT" ]; then
            echo "$ERROR Project name, $CLUSTER_PROJECT, of active stack in cluster and project name in the stack in $APPSODY_CONFIG, $PROJECT, do not match."
            echo "$ERROR stackPolicy validation failed."
            exit 1
        fi
        echo "$INFO Sucessfully validated stack name & project are present, active in the Kabanero CR"

        ##################################################
        #  Main validation between operator and registry #
        ##################################################
        # IgnoreDigests (always)  &  activeDigest (if failure for autopatch)
        CLUSTER_STACK_VERSIONS=$( kubectl get stack $STACK_NAME  -o json | jq -r '.status.versions[].version?' )
        CLUSTER_STACK_DIGESTS=$( kubectl get stack $STACK_NAME -o json | jq -r '.status.versions[].images[].digest.activation?' )
        echo
        echo "$INFO VERSIONS = $CLUSTER_STACK_VERSIONS"
        echo "$INFO DIGESTS  = $CLUSTER_STACK_DIGESTS"   
        
        if [ "$STACK_POLICY" == "ignoreDigest" ]; then
           ignore_digest
        fi

        # Get the target sha256 digest from the image registry. Use the proper credentials depending on what was passed to us
        TARGET_DIGEST=$( skopeo inspect docker://"$IMAGE_REGISTRY_HOST"/"$PROJECT"/"$STACK_NAME":"$VERSION" | jq '.Digest' )

        if [ -z "$TARGET_DIGEST" ]; then
           echo "$APPSODY_CONFIG specifies a stack version of $VERSION , but the image registry does not contain a version tagged with $VERSION, and fails stackPolicy validation."
           exit 1
        fi
 
        # Loop for digests - strictDigest & activeDigest
        for CURRENT_DIGEST in ${CLUSTER_STACK_DIGESTS}
           do              
              if [ "$TARGET_DIGEST" =  "\"sha256:$CURRENT_DIGEST\"" ]; then
                echo 
                echo "$INFO The application stack, "$PROJECT/$STACK_NAME:$VERSION", in $APPSODY_CONFIG is active on this cluster and passes stackPolicy validation."
                exit 0
              else
                 # Not found, iterate to next and pring debug info
                 echo "$INFO Cluster stack digest: $CURRENT_DIGEST"
                 echo "$INFO Project stack version: $VERSION, Project stack digest: $TARGET_DIGEST"
              fi
           done
        echo 
        
        
        if [ "$STACK_POLICY" == "strictDigest" ]; then
           strict_digest
        fi   
        
        if [ "$STACK_POLICY" == "activeDigest" ]; then
           active_digest
        fi   

        # All early exits, we should not get here
        echo "$ERROR stackPolicy of not $STACK_POLICY not recognized"
        exit 1
