## Note: Please be careful following points:
## 1. MySQL 9.x does not work well due to support MD5 function. Please use with the MySQL 8.x.

ARG PHP_IMAGE=docker.io/library/php:8.5-apache

######################################################################
## Stage 1: build PHP extensions with the -dev packages
######################################################################
FROM ${PHP_IMAGE} AS builder

# https://www.php.net/manual/en/image.installation.php
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y --no-install-recommends zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
 && docker-php-ext-install -j"$(nproc)" gd mysqli pdo pdo_mysql

######################################################################
## Stage 2: runtime image (only shared libraries, no -dev packages)
######################################################################
FROM ${PHP_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/yasuhiroabe/dvwa
LABEL org.opencontainers.image.description="Modifed DVWA container image (Original: https://github.com/digininja/DVWA)"
LABEL org.opencontainers.image.licenses="gpl-3.0"
LABEL org.opencontainers.image.authors="YasuhiroABE <yasu@yasundial.org>"

RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y --no-install-recommends libpng16-16t64 libjpeg62-turbo libfreetype6 zlib1g iputils-ping \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Copy the compiled extensions and their ini files from the builder stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

WORKDIR /var/www/html

COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data docker/config.inc.php.dist config/config.inc.php

COPY --chmod=755 docker/run.sh /

EXPOSE 80

ENV DVWA_DB_SERVER=localhost
ENV DVWA_DBNAME=mysql
ENV DVWA_DBUSERNAME=dvwa
ENV DVWA_DBPASSWORD=f3538c7cc848
ENV DVWA_DBPORT=3306

ENV DVWA_WEB_CONTEXTROOT=""
ENV DVWA_ADMIN_PASSWORD=password

ENTRYPOINT ["/run.sh"]
