FROM appsody/appsody-buildah:0.6.0-buildah1.9.0

RUN mkdir -p /scripts


# Copying the scripts required by the pipelines and install_utilities.sh script
COPY /scripts/*.sh  /scripts/
RUN chmod +x /scripts/*.sh

#Executing the script to install the utility tools.
RUN /scripts/install_utilities.sh
