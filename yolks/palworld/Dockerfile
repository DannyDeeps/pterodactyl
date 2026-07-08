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
        iproute2 \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 \
        libssl3:i386 \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && useradd -m -d /home/container -s /bin/bash container

# Install SteamCMD manually to avoid debconf license prompt
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o /tmp/steamcmd.tar.gz \
    && tar -xzf /tmp/steamcmd.tar.gz -C /opt/steamcmd \
    && rm /tmp/steamcmd.tar.gz \
    && chmod +x /opt/steamcmd/steamcmd.sh \
    && find /opt/steamcmd -type f -exec chmod o+x {} + \
    && chmod -R o+w /opt/steamcmd \
    && printf '#!/bin/bash\nSTEAMCMD_DIR="/opt/steamcmd"\nexec "$STEAMCMD_DIR/steamcmd.sh" "$@"\n' > /usr/local/bin/steamcmd \
    && chmod +x /usr/local/bin/steamcmd \
    && ln -sf /usr/local/bin/steamcmd /usr/bin/steamcmd

# Run steamcmd self-update during build so all created files get world-writable permissions
RUN steamcmd +quit 2>/dev/null || true; \
    chmod -R a+w /opt/steamcmd; \
    rm -rf /home/container/Steam

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/container

STOPSIGNAL SIGTERM
CMD ["/entrypoint.sh"]
