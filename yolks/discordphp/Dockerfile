FROM php:8.4.6-alpine3.21

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git composer
  && adduser -D -h /home/container container

USER container
ENV  USER=container HOME=/home/container

WORKDIR /home/container

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]