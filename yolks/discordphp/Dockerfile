FROM debian:bookworm-slim

LABEL author="DannyDeeps" maintainer="dannyhuggins@proton.me"

ARG PHP_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        git \
        apt-transport-https \
        lsb-release \
        ca-certificates \
        wget \
        nginx \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.4 \
        php8.4-cli \
        php8.4-gmp \
        php8.4-json \
        php8.4-zlib \
        php8.4-uv \
        php8.4-mbstring \
        # php8.4-common \
        # php8.4-mysqlnd \
        # php8.4-pdo \
        # php8.4-sybase \
        # php8.4-psr \
        # php8.4-xml \
        # php8.4-bcmath \
        # php8.4-calendar \
        # php8.4-ctype \
        # php8.4-curl \
        # php8.4-dom \
        # php8.4-fileinfo \
        # php8.4-ftp \
        # php8.4-gd \
        # php8.4-gettext \
        # php8.4-iconv \
        # php8.4-igbinary \
        # php8.4-imagick \
        # php8.4-imap \
        # php8.4-intl \
        # php8.4-ldap \
        # php8.4-exif \
        # php8.4-memcache \
        # php8.4-mongodb \
        # php8.4-msgpack \
        # php8.4-mysqli \
        # php8.4-odbc \
        # php8.4-pcov \
        # php8.4-pgsql \
        # php8.4-phar \
        # php8.4-posix \
        # php8.4-ps \
        # php8.4-pspell \
        # php8.4-readline \
        # php8.4-shmop \
        # php8.4-simplexml \
        # php8.4-soap \
        # php8.4-sockets \
        # php8.4-sqlite3 \
        # php8.4-sysvmsg \
        # php8.4-sysvsem \
        # php8.4-sysvshm \
        # php8.4-tokenizer \
        # php8.4-xmlreader \
        # php8.4-xmlwriter \
        # php8.4-xsl \
        # php8.4-zip \
        # php8.4-mailparse \
        # php8.4-memcached \
        # php8.4-inotify \
        # php8.4-maxminddb \
        # php8.4-protobuf \
        # php8.4-opcache \
        # php8.4-dev \
    && wget -q -O /tmp/composer.phar https://getcomposer.org/download/latest-stable/composer.phar \
    && SHA256=$(wget -q -O - https://getcomposer.org/download/latest-stable/composer.phar.sha256) \
    && echo "$SHA256 /tmp/composer.phar" | sha256sum -c - \
    && mv /tmp/composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && rm -rf /var/lib/apt/lists/*

# Create user and set environment variables
RUN useradd -m -d /home/container/ -s /bin/bash container \
    && echo "USER=container" >> /etc/environment \
    && echo "HOME=/home/container" >> /etc/environment

WORKDIR /home/container

STOPSIGNAL SIGINT

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]