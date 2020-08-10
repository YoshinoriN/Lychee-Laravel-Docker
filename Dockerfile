FROM debian:buster-slim

# Set version label
LABEL maintainer="lycheeorg"

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='lychee'
ENV PHP_TZ=UTC

# Arguments
# To use the latest Lychee release instead of master pass `--build-arg TARGET=release` to `docker build`
ARG TARGET=dev

# Add User and Group
RUN \
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER"

# Install base dependencies, clone the repo and install php libraries
RUN \
    set -ev && \
    apt-get update && \
    apt-get install -qy \
    nginx-light \
    php7.3-mysql \
    php7.3-pgsql \
    php7.3-sqlite3 \
    php7.3-imagick \
    php7.3-mbstring \
    php7.3-json \
    php7.3-gd \
    php7.3-xml \
    php7.3-zip \
    php7.3-fpm \
    php7.3-redis \
    curl \
    libimage-exiftool-perl \
    ffmpeg \
    ufraw \
    ufraw-batch \
    git \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    webp \
    composer && \
    cd /var/www/html && \
    git clone --recurse-submodules https://github.com/LycheeOrg/Lychee.git && \
    apt-get install -y composer && \
    cd /var/www/html/Lychee && \
    composer install --no-dev && \
    chown -R www-data:www-data /var/www/html/Lychee && \
    apt-get purge -y git composer && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add custom site to apache
COPY default.conf /etc/nginx/nginx.conf

EXPOSE 80
VOLUME /conf /uploads /sym

WORKDIR /var/www/html/Lychee

COPY entrypoint.sh inject.sh /

RUN chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    mkdir /run/php

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
