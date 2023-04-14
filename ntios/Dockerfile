FROM ubuntu:20.04 as LTPP3G2_NTIOS_APP_BUILDER
#---LABEL about the custom image
LABEL version="0.1"
LABEL description="Required apps and packages to develop on LTPS"
LABEL repository:tag="ltps_init:latest"

#Give net admin rights to allow  discovering devices without snmp/device explorer
#CMD ["--cap-add=NET_ADMIN"] 

#---Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i "s#deb http://\(.*\) #deb [arch=$(dpkg --print-architecture)] http://\1 #g" /etc/apt/sources.list


#---Update and Upgrade
RUN apt-get -y update
RUN apt-get -y upgrade

#---Install mandatory apps
RUN apt-get -y install  git                 \
                    wget                    \
                    curl                    \
                    build-essential	        \
                    g++-arm-linux-gnueabihf \ 
                    gdb-multiarch           \
                    gcc-arm-none-eabi       \
                    libc6-armel-cross       \
                    libc6-dev-armel-cross   \
                    cmake                   \
                    expect                  \
                    fping                   \
                    iputils-ping            \    
                    net-tools               \
                    arping                  \
                    xz-utils                \
                    zstd                    \
                    iproute2                \
                    snmp                    \
                    libsnmp-dev             \
                    jq                      \
                    xxd

#---Enable multiarch
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal main restricted" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal universe" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal multiverse" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-security universe" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse" >> /etc/apt/sources.list
RUN dpkg --add-architecture armhf

#---Update and Upgrade
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install  libgpiod-dev:armhf

#clone the ntios_dev_env repo
RUN cd /root && git clone https://github.com/tibbotech/ntios_dev_env.git
