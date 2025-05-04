FROM php:8.4.6-alpine3.21

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

# RUN apk update \
#   && apk upgrade \
#   && apk add --no-cache \
#     php84 php84-phar php84-curl php84-iconv php84-mbstring php84-openssl php84-zip \
#     p7zip \
#     composer

# # Create user and set environment variables
# RUN adduser -D -h /home/container/ -s /bin/bash container \
#     && echo "USER=container" >> /etc/environment \
#     && echo "HOME=/home/container" >> /etc/environment

RUN apk update && apk add --no-cache git unzip curl \
  && adduser -D -h /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

RUN git clone https://github.com/DannyDeeps/holorick.git . \
  && curl -sS https://getcomposer.org/installer | php \
  && php composer.phar install --no-dev --optimize-autoloader

STOPSIGNAL SIGINT

# Copy entrypoint script
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]