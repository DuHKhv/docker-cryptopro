FROM debian:stretch-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install build-essential wget git cmake unzip gcc -y

ARG PREFIX="/usr/local/ssl"

# Build openssl
ARG OPENSSL_VERSION="OpenSSL_1_1_1d"
ARG OPENSSL_SHA256="a366e3b6d8269b5e563dabcdfe7366d15cb369517f05bfa66f6864c2a60e39e8"
RUN cd /usr/local/src \
  && wget "https://github.com/openssl/openssl/archive/${OPENSSL_VERSION}.zip" -O "${OPENSSL_VERSION}.zip" \
  && unzip "${OPENSSL_VERSION}.zip" -d ./ \
  && cd "openssl-${OPENSSL_VERSION}" \
  && ./config shared -d --prefix=${PREFIX} --openssldir=${PREFIX} && make -j$(nproc) all && make install \
  && mv /usr/bin/openssl /root/ \
  && ln -s ${PREFIX}/bin/openssl /usr/bin/openssl

# Update path of shared libraries
RUN echo "${PREFIX}/lib" >> /etc/ld.so.conf.d/ssl.conf && ldconfig

ARG ENGINES=${PREFIX}/lib/engines-3
