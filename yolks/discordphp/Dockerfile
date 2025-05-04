FROM php:8.4.6-alpine3.21

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
    php84 php84-phar php84-curl php84-iconv php84-mbstring php84-openssl php84-zip \
    p7zip \
    composer

# Create user and set environment variables
RUN adduser -D -h /home/container/ -s /bin/bash container \
    && echo "USER=container" >> /etc/environment \
    && echo "HOME=/home/container" >> /etc/environment

WORKDIR /home/container

STOPSIGNAL SIGINT

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]