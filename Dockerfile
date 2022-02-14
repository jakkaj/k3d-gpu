ARG K3S_TAG="v1.23.1-k3s1"

FROM rancher/k3s:$K3S_TAG as k3s

FROM nvidia/cuda:11.4.0-runtime-ubuntu18.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && \
    apt-get -y install gnupg2 curl

# Install NVIDIA Container Runtime
RUN curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add -

RUN curl -s -L https://nvidia.github.io/nvidia-container-runtime/ubuntu18.04/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list

RUN apt-get update && \
    apt-get -y install nvidia-container-runtime

#RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add - \
#   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list \
#   && curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list \
#   && apt-get update \
#   && apt-get install -y nvidia-docker2


COPY /nvidia/* /tmp
RUN dpkg -i /tmp/libnvidia-container1_1.8.1-1_amd64.deb
RUN dpkg -i /tmp/libnvidia-container-tools_1.8.1-1_amd64.deb


RUN rm /tmp/libnvidia-container-tools_1.8.1-1_amd64.deb && rm /tmp/libnvidia-container1_1.8.1-1_amd64.deb


COPY --from=k3s /bin /bin
COPY --from=k3s /etc /etc

RUN mkdir -p /etc && \
    echo 'hosts: files dns' > /etc/nsswitch.conf



RUN echo "PRETTY_NAME=\"K3s CUDAJORDO\"" > /etc/os-release

RUN chmod 1777 /tmp

# Provide custom containerd configuration to configure the nvidia-container-runtime
RUN mkdir -p /var/lib/rancher/k3s/agent/etc/containerd/

#COPY config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl

# Deploy the nvidia driver plugin on startup
RUN mkdir -p /var/lib/rancher/k3s/server/manifests

COPY device-plugin-daemonset.yaml /var/lib/rancher/k3s/server/manifests/nvidia-device-plugin-daemonset.yaml

VOLUME /var/lib/kubelet
VOLUME /var/lib/rancher/k3s
VOLUME /var/lib/cni
VOLUME /var/log

ENV PATH="$PATH:/bin/aux"


ENV CRI_CONFIG_FILE="/var/lib/rancher/k3s/agent/etc/crictl.yaml"



ENTRYPOINT ["/bin/k3s"]
CMD ["agent"]