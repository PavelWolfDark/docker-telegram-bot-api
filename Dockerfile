ARG BASE=ubuntu
ARG UBUNTU_VERSION=22.04
ARG ALPINE_VERSION=3.16
ARG TELEGRAM_BOT_API_VERSION=6.3

FROM ubuntu:${UBUNTU_VERSION} AS ubuntu

FROM alpine:${ALPINE_VERSION} AS alpine

FROM ubuntu AS ubuntu-telegram-bot-api-6.3-build
ENV TELEGRAM_BOT_API_VERSION=6.3
ENV TDLIB_VERSION=1.8.8
RUN \
  set -eux \
  && apt-get update\
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    git \
    make \
    zlib1g-dev \
    libssl-dev \
    gperf \
    cmake \
    clang-14 \
    libc++-dev \
    libc++abi-dev \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN \
  set -eux \
  && git clone https://github.com/tdlib/td.git tdlib \
  && cd tdlib \
  && git reset --hard 'bbe37ee594d97f3c7820dd23ebcd9c9b8dac51a0'
RUN \
  set -eux \
  && git clone https://github.com/tdlib/telegram-bot-api.git telegram-bot-api \
  && cd telegram-bot-api \
  && git reset --hard '571baeead026fd6c671e00d6c5cf76d2bdf8eeb1'
WORKDIR /dist
RUN \
  set -eux \
  && cd /src/telegram-bot-api \
  && cp -r ../tdlib/* td/ \
  && mkdir build \
  && cd build \
  && CXXFLAGS='-stdlib=libc++' \
    CC=/usr/bin/clang-14 \
    CXX=/usr/bin/clang++-14 \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/dist .. \
  && cmake --build . --target install \
  && strip /dist/bin/telegram-bot-api

FROM scratch AS ubuntu-telegram-bot-api-6.3-release
COPY --from=ubuntu-telegram-bot-api-6.3-build /dist /

FROM ubuntu AS ubuntu-telegram-bot-api-6.3-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    zlib1g \
    libssl3 \
    libc++1 \
    libc++abi1 \
    gosu \
  && rm -rf /var/lib/apt/lists/*
COPY --from=ubuntu-telegram-bot-api-6.3-release / /usr/
RUN \
  set -eux \
  && groupadd -g "${GID}" telegram-bot-api \
  && useradd -u "${UID}" -g telegram-bot-api telegram-bot-api
VOLUME \
  /var/lib/telegram-bot-api \
  /var/tmp/telegram-bot-api \
  /var/log/telegram-bot-api
EXPOSE 8081
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["telegram-bot-api"]

FROM alpine AS alpine-telegram-bot-api-6.3-build
ENV TELEGRAM_BOT_API_VERSION=6.3
ENV TDLIB_VERSION=1.8.8
RUN \
  set -eux \
  && apk add --no-cache \
    alpine-sdk \
    linux-headers \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    cmake
WORKDIR /src
RUN \
  set -eux \
  && git clone https://github.com/tdlib/td.git tdlib \
  && cd tdlib \
  && git reset --hard 'bbe37ee594d97f3c7820dd23ebcd9c9b8dac51a0'
RUN \
  set -eux \
  && git clone https://github.com/tdlib/telegram-bot-api.git telegram-bot-api \
  && cd telegram-bot-api \
  && git reset --hard '571baeead026fd6c671e00d6c5cf76d2bdf8eeb1'
WORKDIR /dist
RUN \
  set -eux \
  && cd /src/telegram-bot-api \
  && cp -r ../tdlib/* td/ \
  && mkdir build \
  && cd build \
  && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/dist .. \
  && cmake --build . --target install \
  && strip /dist/bin/telegram-bot-api

FROM scratch AS alpine-telegram-bot-api-6.3-release
COPY --from=alpine-telegram-bot-api-6.3-build /dist /

FROM alpine AS alpine-telegram-bot-api-6.3-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apk add --no-cache \
    libstdc++ \
    zlib \
    openssl \
    su-exec
COPY --from=alpine-telegram-bot-api-6.3-release / /usr/
RUN \
  set -eux \
  && addgroup -g "${GID}" telegram-bot-api \
  && adduser -u "${UID}" -G telegram-bot-api -D telegram-bot-api
VOLUME \
  /var/lib/telegram-bot-api \
  /var/tmp/telegram-bot-api \
  /var/log/telegram-bot-api
EXPOSE 8081
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["telegram-bot-api"]

FROM ubuntu AS ubuntu-telegram-bot-api-6.2-build
ENV TELEGRAM_BOT_API_VERSION=6.2
ENV TDLIB_VERSION=1.8.5
RUN \
  set -eux \
  && apt-get update\
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    git \
    make \
    zlib1g-dev \
    libssl-dev \
    gperf \
    cmake \
    clang-14 \
    libc++-dev \
    libc++abi-dev \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN \
  set -eux \
  && git clone https://github.com/tdlib/td.git tdlib \
  && cd tdlib \
  && git reset --hard 'd9cfcf88fe4ad06dae1716ce8f66bbeb7f9491d9'
RUN \
  set -eux \
  && git clone https://github.com/tdlib/telegram-bot-api.git telegram-bot-api \
  && cd telegram-bot-api \
  && git reset --hard 'f59097ab16232995ed5bdc3feff4f3ca82c9b127'
WORKDIR /dist
RUN \
  set -eux \
  && cd /src/telegram-bot-api \
  && cp -r ../tdlib/* td/ \
  && mkdir build \
  && cd build \
  && CXXFLAGS='-stdlib=libc++' \
    CC=/usr/bin/clang-14 \
    CXX=/usr/bin/clang++-14 \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/dist .. \
  && cmake --build . --target install \
  && strip /dist/bin/telegram-bot-api

FROM scratch AS ubuntu-telegram-bot-api-6.2-release
COPY --from=ubuntu-telegram-bot-api-6.2-build /dist /

FROM ubuntu AS ubuntu-telegram-bot-api-6.2-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    zlib1g \
    libssl3 \
    libc++1 \
    libc++abi1 \
    gosu \
  && rm -rf /var/lib/apt/lists/*
COPY --from=ubuntu-telegram-bot-api-6.2-release / /usr/
RUN \
  set -eux \
  && groupadd -g "${GID}" telegram-bot-api \
  && useradd -u "${UID}" -g telegram-bot-api telegram-bot-api
VOLUME \
  /var/lib/telegram-bot-api \
  /var/tmp/telegram-bot-api \
  /var/log/telegram-bot-api
EXPOSE 8081
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["telegram-bot-api"]

FROM alpine AS alpine-telegram-bot-api-6.2-build
ENV TELEGRAM_BOT_API_VERSION=6.2
ENV TDLIB_VERSION=1.8.5
RUN \
  set -eux \
  && apk add --no-cache \
    alpine-sdk \
    linux-headers \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    cmake
WORKDIR /src
RUN \
  set -eux \
  && git clone https://github.com/tdlib/td.git tdlib \
  && cd tdlib \
  && git reset --hard 'd9cfcf88fe4ad06dae1716ce8f66bbeb7f9491d9'
RUN \
  set -eux \
  && git clone https://github.com/tdlib/telegram-bot-api.git telegram-bot-api \
  && cd telegram-bot-api \
  && git reset --hard 'f59097ab16232995ed5bdc3feff4f3ca82c9b127'
WORKDIR /dist
RUN \
  set -eux \
  && cd /src/telegram-bot-api \
  && cp -r ../tdlib/* td/ \
  && mkdir build \
  && cd build \
  && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/dist .. \
  && cmake --build . --target install \
  && strip /dist/bin/telegram-bot-api

FROM scratch AS alpine-telegram-bot-api-6.2-release
COPY --from=alpine-telegram-bot-api-6.2-build /dist /

FROM alpine AS alpine-telegram-bot-api-6.2-deploy
ARG UID=1000
ARG GID=1000
RUN \
  set -eux \
  && apk add --no-cache \
    libstdc++ \
    zlib \
    openssl \
    su-exec
COPY --from=alpine-telegram-bot-api-6.2-release / /usr/
RUN \
  set -eux \
  && addgroup -g "${GID}" telegram-bot-api \
  && adduser -u "${UID}" -G telegram-bot-api -D telegram-bot-api
VOLUME \
  /var/lib/telegram-bot-api \
  /var/tmp/telegram-bot-api \
  /var/log/telegram-bot-api
EXPOSE 8081
COPY --chmod=700 docker-entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["telegram-bot-api"]

FROM ${BASE}-telegram-bot-api-${TELEGRAM_BOT_API_VERSION}-build AS build
LABEL maintainer="cyberviking@darkwolf.team"

FROM ${BASE}-telegram-bot-api-${TELEGRAM_BOT_API_VERSION}-release AS release
LABEL maintainer="cyberviking@darkwolf.team"

FROM ${BASE}-telegram-bot-api-${TELEGRAM_BOT_API_VERSION}-deploy AS deploy
LABEL maintainer="cyberviking@darkwolf.team"