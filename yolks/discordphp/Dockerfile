FROM php:8.4.6-alpine3.21

# RUN apk add --no-cache --update curl ca-certificates openssl git tar bash sqlite fontconfig \
#     && adduser --disabled-password --home /home/container container
RUN adduser --disabled-password --home /home/container container

USER container
ENV  USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/ash", "/entrypoint.sh"]