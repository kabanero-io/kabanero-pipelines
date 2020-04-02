FROM appsody/appsody-buildah:0.5.8-buildah1.9.0

#Running the kubectl installation script in above base image
COPY /install_utilities.sh /root/
RUN chmod +x /root/install_utilities.sh
RUN /root/install_utilities.sh
