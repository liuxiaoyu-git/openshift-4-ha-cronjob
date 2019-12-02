FROM ubi8/ubi:latest

ARG oc_version=4.2

RUN yum -y install python3-pip \
 && pip3 install ansible \
 && wget -O /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/${oc_version}/linux/oc.tar.gz
 && tar xvf -C /usr/bin/ /tmp/oc.tar.gz

COPY job /usr/bin/job

ENTRYPOINT /usr/bin/job