#!/bin/sh
# This script is fetching the values of 'registries.insecure' from the 'image.config.openshift.io/cluster' resource
# that will be used by the tasks for setting the
# 'registries.insecure' in '/etc/containers/registries.conf' file of each step container in the pipelines.
# Reference Redhat documentation link : https://docs.openshift.com/container-platform/4.2/openshift_images/image-configuration.html
        
internal_registry_internal_url=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.status.internalRegistryHostname}")
insecure_registries_string=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.spec.registrySources.insecureRegistries[*]}")
        
if [[ ! -z "$insecure_registries_string" ]]; then
   echo "The insecure image registry list found"

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
