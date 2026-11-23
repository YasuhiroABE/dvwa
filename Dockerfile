## Note: Please be careful following points:
## 1. MySQL 9.x does not work well due to support MD5 function. Please use with the MySQL 8.x.
## 2. The php:*-alpine image has no Apache module (mod_php). Apache from the Alpine
##    packages runs PHP scripts through php-cgi with mod_fcgid (see docker/httpd-dvwa.conf).

ARG PHP_IMAGE=docker.io/library/php:8.5-alpine

######################################################################
## Stage 1: build PHP extensions with the -dev packages
######################################################################
FROM ${PHP_IMAGE} AS builder

# https://www.php.net/manual/en/image.installation.php
# docker-php-ext-* installs the $PHPIZE_DEPS build tools automatically on Alpine.
RUN apk add --no-cache zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev \
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

RUN apk add --no-cache apache2 apache-mod-fcgid libpng libjpeg-turbo freetype zlib iputils-ping \
 && sed -i \
      -e 's!^User apache!User www-data!' \
      -e 's!^Group apache!Group www-data!' \
      -e 's!/var/www/localhost/htdocs!/var/www/html!g' \
      -e 's!^ErrorLog .*!ErrorLog /dev/stderr!' \
      -e 's!^\(\s*CustomLog\) .* combined!\1 /dev/stdout combined!' \
      /etc/apache2/httpd.conf \
 && mkdir -p /run/apache2/fcgid && chown www-data:www-data /run/apache2/fcgid

COPY docker/httpd-dvwa.conf /etc/apache2/conf.d/mod_fcgid.conf

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
