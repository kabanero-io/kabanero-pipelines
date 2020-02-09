FROM quay.io/buildah/stable:v1.9.0

# Create repo file for yum to pull kubectl from
RUN echo "[kubernetes]" > /etc/yum.repos.d/kubernetes.repo
RUN echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "enabled=1"  >> /etc/yum.repos.d/kubernetes.repo
RUN echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo

RUN useradd build; yum -y update; yum -y reinstall shadow-utils; yum -y install skopeo jq kubectl



