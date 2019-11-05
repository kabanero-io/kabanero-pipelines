FROM registry.access.redhat.com/ubi8:latest

# Create repo file for yum to pull kubectl from
RUN echo "[kubernetes]" > /etc/yum.repos.d/kubernetes.repo
RUN echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "enabled=1"  >> /etc/yum.repos.d/kubernetes.repo
RUN echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
RUN echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo

# Install kubectl
RUN yum install -y kubectl
