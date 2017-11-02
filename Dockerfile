FROM nvidia/cuda:8.0-devel-ubuntu16.04

MAINTAINER Ewan Barr "ebarr@mpifr-bonn.mpg.de"

# Suppress debconf warnings
ENV DEBIAN_FRONTEND noninteractive

# Create space for ssh daemon and update the system
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu trusty main multiverse' >> /etc/apt/sources.list && \
    apt-get -y check && \
    apt-get -y update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common python-software-properties && \
    apt-get -y update --fix-missing && \
    apt-get -y upgrade

# Install dependencies
RUN apt-get --no-install-recommends -y install \
    build-essential \
    git \
    libboost-all-dev \
    cmake \
    libfftw3-3 \
    libfftw3-bin \
    libfftw3-dev \
    libfftw3-single3 \
    cvs \
    csh \
    autotools-dev \
    automake \
    autogen \
    autoconf \
    hwloc \
    libhwloc-dev \
    libnuma-dev \
    libnuma1 \
    expect \
    libtool \
    gcc \
    wget \
    gsl-bin \
    libgsl-dev \
    libgsl2 \
    pkg-config

RUN mkdir /software/ && \
    cd /software/ && \
    git clone https://gitlab.com/SKA-TDT/cheetah.git && \
    git clone https://gitlab.com/SKA-TDT/panda.git && \
    git clone https://github.com/AstroAccelerateOrg/astro-accelerate.git

RUN cd /software/astro-accelerate/ && \
    git checkout aa_interface && \
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true ../ && \
    make -j 16 && \
    make install

RUN cd /software/panda/ && \
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true ../ && \
    make -j 16 && \
    make install

# Install PSRDADA
ENV PSRHOME /software/
WORKDIR $PSRHOME
COPY psrdada_cvs_login $PSRHOME/psrdada_cvs_login
RUN ls -lrt psrdada_cvs_login && \
    chmod +x psrdada_cvs_login &&\
    sleep 1 &&\
    ./psrdada_cvs_login && \
    cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada
ENV PSRDADA_HOME $PSRHOME/psrdada
WORKDIR $PSRDADA_HOME
COPY PsrdadaMakefile.am $PSRDADA_HOME/Makefile.am
RUN mkdir build/ && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    make clean
ENV PSRDADA_BUILD $PSRHOME
ENV PACKAGES $PSRDADA_BUILD

RUN cd /software/cheetah/ && \
    git checkout psrdada && \
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true -DENABLE_PSRDADA=true ../ && \
    make -j 16

