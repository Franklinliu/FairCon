FROM ubuntu:bionic
MAINTAINER  Liu Ye <li0003ye@ntu.edu.sg>

ENV DEBIAN_FRONTEND noninteractive


ENV CMAKE_VERSION 3.16
ENV BUILD 5

RUN \
  apt-get update &&\
  apt-get -y install \
          software-properties-common \
          vim \
          pwgen \
          unzip \
          curl \
          git-core \
          wget  \
          make  \
	  gcc \
          g++ \
          libssl-dev \
          python\ 
          tar
RUN \
  mkdir temp && \
  cd /temp && \
  wget https://cmake.org/files/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.$BUILD.tar.gz &&\
  tar -xzvf cmake-$CMAKE_VERSION.$BUILD.tar.gz && \
  cd cmake-$CMAKE_VERSION.$BUILD/ &&\
  ./bootstrap && \
  make -j$(nproc) && \
  make install 

RUN \
  mkdir -p temp && \
  cd /temp && \
  wget  http://archive.ubuntu.com/ubuntu/pool/universe/b/boost-defaults/libboost-all-dev_1.65.1.0ubuntu1_amd64.deb && \
  dpkg -i  ./libboost-all-dev_1.65.1.0ubuntu1_amd64.deb ;\
  apt-get  -y install -f && \
  dpkg -i  ./libboost-all-dev_1.65.1.0ubuntu1_amd64.deb 

RUN \
   mkdir -p temp && cd /temp &&\
   git clone https://github.com/Z3Prover/z3.git &&\
   cd z3 && \ 
   python scripts/mk_make.py &&\
   cd build &&\
   make &&\
   make install 
# remove tempory files
RUN \
 rm -rf /temp && \
 rm -rf /var/lib/apt/lists/*

RUN \
    mkdir  -p /home/fairness

WORKDIR /home/fairness
RUN \
    git clone https://github.com/Franklinliu/FairCon.git &&\
    cp -rf FairCon/contracts contracts &&\
    cp -rf FairCon/scripts scripts &&\
    cp -rf FairCon/src source &&\
    rm -rf FairCon &&\
    cd source &&\
    mkdir -p build && cd build &&\
    rm -rf * &&\
    cmake .. && make  &&\
    cp /home/fairness/source/build/solse/faircon /usr/bin/faircon &&\
    rm -rf /home/fairness/source 

#entrypoint
CMD ["bash", "./scripts/demo.sh"]

