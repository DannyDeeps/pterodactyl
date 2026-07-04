FROM debian:bookworm-slim

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container

RUN dpkg --add-architecture i386 \
    && rm -f /etc/apt/sources.list.d/debian.sources \
    && echo "deb http://deb.debian.org/debian bookworm main non-free contrib" > /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian bookworm-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/debian-security bookworm-security main non-free contrib" >> /etc/apt/sources.list \
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
        libssl3:i386 \
        openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && useradd -m -d /home/container -s /bin/bash container

# Install SteamCMD manually to avoid debconf license prompt
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o /tmp/steamcmd.tar.gz \
    && tar -xzf /tmp/steamcmd.tar.gz -C /opt/steamcmd \
    && rm /tmp/steamcmd.tar.gz \
    && ln -sf /opt/steamcmd/steamcmd.sh /usr/local/bin/steamcmd \
    && ln -sf /opt/steamcmd/steamcmd.sh /usr/bin/steamcmd \
    && chmod +x /opt/steamcmd/steamcmd.sh

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
WORKDIR /home/container

STOPSIGNAL SIGTERM
CMD ["/entrypoint.sh"]
