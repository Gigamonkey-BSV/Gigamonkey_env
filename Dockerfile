FROM gigamonkey/gigamonkey-base-dev:v1.1.4

ENV DEBIAN_FRONTEND=noninteractive
ARG DATA_VERSION
ARG GIGAMONKEY_VERSION
ARG NUM_JOBS=8

RUN cmake --version

#data
WORKDIR /tmp
RUN git clone https://github.com/DanielKrawisz/data.git
WORKDIR /tmp/data
RUN git checkout -q ${DATA_VERSION}
RUN cmake -G Ninja -B build -S . -DPACKAGE_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build -j 4
RUN cmake --install build

#gigamonkey
WORKDIR /tmp
RUN git clone https://github.com/Gigamonkey-BSV/Gigamonkey.git
WORKDIR /tmp/Gigamonkey
RUN git checkout -q ${GIGAMONKEY_VERSION}
RUN cmake -G Ninja  -B build -S . -DPACKAGE_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build -j 4
RUN cmake --install build

