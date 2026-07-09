FROM ghcr.io/dannydeeps/yolks:steamcmd

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*
