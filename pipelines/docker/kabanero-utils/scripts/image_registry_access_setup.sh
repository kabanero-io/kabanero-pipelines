#!/bin/sh
# This script section is fetching the values of 'registries.insecure' from the 'image.config.openshift.io/cluster' resource
# that will be used by the tasks for setting the
# 'registries.insecure' in '/etc/containers/registries.conf' file of each step container in the pipelines.
# Reference Redhat documentation link : https://docs.openshift.com/container-platform/4.2/openshift_images/image-configuration.html
        
# Tracing prefixes
INFO="[INFO]"
WARNING="[WARNING]"
ERROR="[ERROR]"

internal_registry_internal_url=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.internalRegistryHostname}")
insecure_registries_string=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.spec.registrySources.insecureRegistries[*]}")
        
if [[ ! -z "$insecure_registries_string" ]]; then
   echo "$INFO The insecure image registry list found"

   IFS=' ' # space is set as delimiter
   read -ra ADDR <<< ''"$insecure_registries_string"'' # str is read into an array as tokens separated by IFS
   for i in ''"${ADDR[@]}"''; do # access each element of array
      if [[ ! -z ''"$INSECURE_REGISTRTY"'' ]]; then
         INSECURE_REGISTRTY=''"$INSECURE_REGISTRTY"', '"'"''"$i"''"'"''
      else
         INSECURE_REGISTRTY=''"'"''"$i"''"'"''
      fi
   done
              
   if [[ (! -z "internal_registry_internal_url" ) && ( "$INSECURE_REGISTRTY" != *"$internal_registry_internal_url"* ) ]]; then
      INSECURE_REGISTRTY=''"$INSECURE_REGISTRTY"', '"'"''"$internal_registry_internal_url"''"'"''
   fi
else
   if [[ ! -z "internal_registry_internal_url" ]]; then
      INSECURE_REGISTRTY=''"'"''"$internal_registry_internal_url"''"'"''
   fi
fi
           
#example original string :
#[registries.insecure]
#registries = []
ORIGINAL_STRING='\[registries\.insecure\]\nregistries = \[\]'
           
#example replace string
#[registries.insecure]
#registries = ['pqr.com', 'abc.com']
REPLACE_STRING='\[registries\.insecure\]\nregistries = \['"$INSECURE_REGISTRTY"'\]'
           
sed -i -e ':a;N;$!ba;s|'"$ORIGINAL_STRING"'|'"$REPLACE_STRING"'|' /etc/containers/registries.conf
echo "$INFO The image registries that got added successfully to insecure list are = [ $INSECURE_REGISTRTY ]"
############

# This script section will be used in later tasks to fetch the trusted ca certificates configured 
# in a configmap which is set in the 'image.config.openshift.io/cluster' resource by the user. If such additional ca certificates found, we will copy the certificate values and generate 'ca.crt' as '/etc/docker/certs.d/<hostname>/ca.crt' for each certificate on the container.
# Reference Redhat documentation link : https://docs.openshift.com/container-platform/4.2/openshift_images/image-configuration.html

#Check if cluster resource 'image.config.openshift.io/cluster' has any additional_trusted_ca setup by user
#If yes we pull the certificate values from the configmap setup there and create ca.crt files for each hostname with 
#the certificate value given by the user in location '/etc/docker/certs.d/[hostname]/ca.crt'
additonal_trusted_CA=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.spec.additionalTrustedCA.name}")

if [[ ! -z "$additonal_trusted_CA" ]]; then
   echo "$INFO additonal_trusted_CA=$additonal_trusted_CA found in the image.config.openshift.io/cluster resource, setting up the certificates in /etc/docker/certs.d/ location"        
   config_map_key_count=$(kubectl get configmap $additonal_trusted_CA -n openshift-config -o json | jq '.data' | jq 'keys | length')

   for ((i=0;i<config_map_key_count;i++));do
       key=$(kubectl get configmap $additonal_trusted_CA -n openshift-config -o json | jq '.data' | jq 'keys['"$i"']')

       #sed command to remove double quotes from beginning and the end of the above key(example key="abc.pqr.com") variable value
       key=$(sed -e 's/^"//' -e 's/"$//' <<<$key)

       #sed command to replace '.' with '\.' to escape it while using ahead to fetch that key's value from the map
       key_hostname_with_escaped_dot=$(sed -e 's/\./\\./g' <<< "$key")
       cert_value=$(kubectl get configmap $additonal_trusted_CA -n openshift-config --output="jsonpath={.data.$key_hostname_with_escaped_dot}")

       #sed command to update the configmap key to replace '..' with ':' example 'image-registry.openshift-image-registry.svc..5000' to image-registry.openshift-image-registry.svc:5000
       key=$(sed -e 's/\.\./:/g' <<< "$key")
       mkdir -p /etc/docker/certs.d/$key
       echo "$cert_value" | sudo tee -a /etc/docker/certs.d/$key/ca.crt
       echo "$INFO Certificate added for the host $key at location /etc/docker/certs.d/$key/"
   done
fi


