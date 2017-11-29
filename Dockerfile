FROM nvidia/cuda:8.0-devel-ubuntu16.04

RUN apt-get update &&\
    apt-get --no-install-recommends -y install \
    libboost-all-dev \
    git \
    csh \
    cmake \
    autotools-dev \
    autoconf \
    automake \
    hwloc \  
    libhwloc-dev \
    libnuma-dev \
    libnuma1 \
    libtool \
    pkg-config \
    libfftw3-3 \
    libfftw3-bin \
    libfftw3-dev \
    libfftw3-single3 \
    ca-certificates 

WORKDIR /software/
    
#install Psrdada
RUN git clone git://git.code.sf.net/p/psrdada/code psrdada &&\
    cd /software/psrdada &&\
    echo "ACLOCAL_AMFLAGS = -I config" > Makefile.am &&\
    echo "SUBDIRS = Management 3rdparty src scripts config" >> Makefile.am &&\
    echo "EXTRA_DIST = cudalt.py" >> Makefile.am &&\
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j 32&& \
    make install && \
    make clean
ENV PSRDADA_BUILD /usr/local

#install Panda
RUN git clone https://gitlab.com/SKA-TDT/panda.git &&\
    cd panda/ &&\
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true ../ && \
    make -j 6 && \
    make install

#install AstroAccelerate
RUN git clone https://github.com/AstroAccelerateOrg/astro-accelerate.git &&\
    cd /software/astro-accelerate/ && \
    git checkout aa_interface && \
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true ../ && \
    make -j 16 && \
    make install

#install Cheetah
RUN git clone https://gitlab.com/SKA-TDT/cheetah.git &&\
    cd /software/cheetah/ && \
    git checkout dev && \
    mkdir build/ && \
    cd build/ && \
    cmake -DENABLE_CUDA=true -DENABLE_PSRDADA=true ../ && \
    make -j 6

