FROM ubuntu:18.04

LABEL maintaier "Pete Dietl <petedietl@gmail.com>"

SHELL [ "/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        make \
        wget

ARG BATS_VERSION=1.1.0
RUN wget https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz && \
    tar xf v${BATS_VERSION}.tar.gz && \
    pushd bats-core-${BATS_VERSION} && \
    ./install.sh /usr/local && \
    popd && \
    rm -rf bats-core-${BATS_VERSION} && \
    rm v${BATS_VERSION}.tar.gz
