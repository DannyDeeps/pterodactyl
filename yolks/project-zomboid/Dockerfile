FROM debian:bookworm-slim

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        unzip \
        wget \
        locales \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 \
        libcurl4-gnutls-dev:i386 \
        libssl3:i386 \
        openjdk-17-jre-headless \
        steamcmd \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && useradd -m -d /home/container -s /bin/bash container

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
WORKDIR /home/container

STOPSIGNAL SIGTERM
CMD ["/entrypoint.sh"]
