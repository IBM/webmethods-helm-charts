ARG __from_image=registry.redhat.io/openshift4/ose-cli


# trunk-ignore(checkov/CKV_DOCKER_7,hadolint/DL3006)
FROM ${__from_image}

# trunk-ignore(hadolint/DL4006,hadolint/DL3008)
RUN dnf -y update && dnf -y upgrade \
    && dnf -y install \
        ca-certificates \
        curl \
        git \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && curl https://get.trunk.io -fsSL | bash

ARG __gid=756
ARG __gname=wmhelm
ARG __uid=756
ARG __uname=wmhelm
ARG __uhome=/home/${__uname}
ARG __workspace_folder=/workspace/project

RUN groupadd -g ${__gid} ${__gname} \
    && useradd -l -rm -d  ${__uhome} -s /bin/bash -g ${__gid} -u ${__uid} ${__uname} \
    && mkdir -p ${__workspace_folder} \
    && chown ${__uname}:${__gname} ${__workspace_folder} \
    && chown -R ${__uname}:${__gname} /usr/local/bin

USER ${__uname}

HEALTHCHECK --interval=60s --timeout=60s --start-period=25s --retries=3  CMD exit 0
