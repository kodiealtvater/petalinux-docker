FROM ubuntu:16.04

# build with "docker build --build-arg PETA_VERSION=2020.2 --build-arg PETA_RUN_FILE=petalinux-v2020.2-final-installer.run -t petalinux:2020.2 ."

# install dependences:
RUN apt-get update &&  DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  openssh-client \
  vim \
  tar \
  bsdmainutils \
  build-essential \
  sudo \
  tofrodos \
  iproute2 \
  gawk \
  firefox \
  net-tools \
  expect \
  libncurses5-dev \
  tftpd \
  update-inetd \
  libssl-dev \
  flex \
  bison \
  libselinux1 \
  gnupg \
  wget \
  socat \
  gcc-multilib \
  libsdl1.2-dev \
  libglib2.0-dev \
  lib32z1-dev \
  libgtk2.0-0 \
  screen \
  pax \
  diffstat \
  xvfb \
  xterm \
  texinfo \
  gzip \
  unzip \
  cpio \
  chrpath \
  autoconf \
  lsb-release \
  libtool \
  libtool-bin \
  locales \
  kmod \
  git \
  rsync \
  bc \
  u-boot-tools \
  python \
  curl \
  device-tree-compiler \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 &&  apt-get update &&  \
      DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
      zlib1g:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG PETA_VERSION
ARG PETA_RUN_FILE

RUN locale-gen en_US.UTF-8 && update-locale

#make a Vivado user
RUN adduser --disabled-password --gecos '' vivado && \
  usermod -aG sudo vivado && \
  echo "vivado ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY accept-eula.sh ${PETA_RUN_FILE} /

# run the install
RUN chmod a+rx /${PETA_RUN_FILE} && \
  chmod a+rx /accept-eula.sh && \
  mkdir -p /opt/Xilinx && \
  chmod 777 /tmp /opt/Xilinx && \
  cd /tmp && \
  sudo -u vivado -i /accept-eula.sh /${PETA_RUN_FILE} /opt/Xilinx/petalinux && \
  rm -f /${PETA_RUN_FILE} /accept-eula.sh

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8
RUN mkdir /home/vivado/project
WORKDIR /home/vivado/project

#add vivado tools to path
RUN echo "source /opt/Xilinx/petalinux/settings.sh" >> /home/vivado/.bashrc

# Turn of SSL certificates (issue w/ git and grabbing repos)
RUN git config --global http.sslVerify false

# Set up SSH for access to upstream REPO using private/public key pair (previously generated)
RUN git config --global user.email "githubdevops@tomorrow.io" && \
    git config --global user.name "githubdevops" && \
    git config --global alias.st "status" && \
    git config --global alias.co "checkout" && \
    git config --global push.default simple && \
    mkdir -p ${HOME}/.ssh && \
    chmod 700 ${HOME}/.ssh && \
    config_file=${HOME}/.ssh/config && \
    touch $config_file && \
    chmod 754 $config_file && \
    echo "Host github.com" > $config_file && \
    echo "User "githubdevops@tomorrow.io"" >> $config_file && \
    echo "PreferredAuthentications publickey" >> $config_file && \
    echo "IdentityFile ${HOME}/.ssh/key" >> $config_file && \
    echo "StrictHostKeyChecking no" >> $config_file && \
    echo "ForwardAgent yes" >> $config_file && \
    echo "ForwardX11   no" >> $config_file
# Copy Keys to correct directory for SSH
COPY key ${HOME}/.ssh/
COPY key.pub ${HOME}/.ssh/

# install gh (github cli) 
ENV VERSION=2.0.0
RUN wget https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz
RUN tar xvf gh_${VERSION}_linux_amd64.tar.gz
RUN sudo cp gh_${VERSION}_linux_amd64/bin/gh /usr/local/bin/
