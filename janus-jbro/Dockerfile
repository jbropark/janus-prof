FROM ubuntu:focal
RUN echo ' \n\
APT::Periodic::Update-Package-Lists "0";\n\
APT::Periodic::Unattended-Upgrade "1";\n'\
> /etc/apt/apt.conf.d/20auto-upgrades

RUN set -x \
    && apt-get update \
# Set timezone noninteractive
    && apt-get install -yq tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get install -y build-essential snapd aptitude git wget \
    python3 python3-pip python3-setuptools python3-wheel ninja-build \
    libgirepository1.0-dev libunwind-dev apt-utils gdb \
    && aptitude install -y libmicrohttpd-dev libjansson-dev \
    libssl-dev libglib2.0-dev libopus-dev libogg-dev \
    libconfig-dev libavutil-dev libavcodec-dev libavformat-dev \
    libcurl4-openssl-dev pkg-config gengetopt libtool automake curl jq httpie vim screen
RUN set -x \
    && wget https://cmake.org/files/v3.16/cmake-3.16.2.tar.gz \
    && tar -xvzf cmake-3.16.2.tar.gz \
    && cd cmake-3.16.2 \
    && ./bootstrap --prefix=/usr/local \
    && make && make install
RUN set -x \
    && python3 -m pip install meson \
    && python3 -m pip install ninja
RUN set -x \
    && wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz \
    && tar xfv v2.2.0.tar.gz  \
    && cd libsrtp-2.2.0/ \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library && make install
RUN set -x \
    && git clone https://github.com/warmcat/libwebsockets.git \
    && cd libwebsockets \
    && mkdir build \
    && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install
RUN set -x \
    && git clone https://gitlab.freedesktop.org/libnice/libnice \
    && cd libnice \
    && meson --prefix=/usr build && ninja -C build && ninja -C build install
RUN export JANUS_WITH_POSTPROCESSING
RUN set -x \
    && git clone https://github.com/jbropark/janus-gateway.git \
    && cd janus-gateway \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --disable-rabbitmq --disable-data-channels --disable-mqtt \
    && make \
    && make install \
    && make configs
RUN adduser --disabled-password --gecos '' janus
USER janus
RUN /opt/janus/bin/janus -h
CMD ["/bin/bash"]

