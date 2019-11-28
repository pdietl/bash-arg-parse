FROM ubuntu:18.04

LABEL maintaier "Pete Dietl <petedietl@gmail.com>"

SHELL [ "/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        make \
        wget \
        xz-utils

ARG BATS_VERSION=1.1.0
RUN wget https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz && \
    tar xf v${BATS_VERSION}.tar.gz && \
    pushd bats-core-${BATS_VERSION} && \
    ./install.sh /usr/local && \
    popd && \
    rm -r bats-core-${BATS_VERSION} && \
    rm v${BATS_VERSION}.tar.gz

ARG SHELLCHECK_VERSION=0.7.0
RUN wget https://storage.googleapis.com/shellcheck/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz && \
   tar xf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz && \
   install -Dt /usr/local/bin shellcheck-v${SHELLCHECK_VERSION}/shellcheck && \
   rm -r shellcheck-v${SHELLCHECK_VERSION} && \
   rm shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz
