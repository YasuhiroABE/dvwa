FROM docker.io/library/php:8-apache

LABEL org.opencontainers.image.source=https://github.com/yasuhiroabe/dvwa
LABEL org.opencontainers.image.description="Modifed DVWA container image (Original: https://github.com/digininja/DVWA)"
LABEL org.opencontainers.image.licenses="gpl-3.0"
LABEL org.opencontainers.image.authors="YasuhiroABE <yasu@yasundial.org>"

WORKDIR /var/www/html

# https://www.php.net/manual/en/image.installation.php
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
 && docker-php-ext-install gd mysqli pdo pdo_mysql

COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data docker/config.inc.php.dist config/config.inc.php

COPY --chmod=755 docker/run.sh /

EXPOSE 80

ENV DVWA_DB_SERVER localhost
ENV DVWA_DBNAME mysql
ENV DVWA_DBUSERNAME dvwa
ENV DVWA_DBPASSWORD f3538c7cc848
ENV DVWA_DBPORT 3306

ENV DVWA_WEB_CONTEXTROOT /
ENV DVWA_ADMIN_PASSWORD password

ENTRYPOINT ["/run.sh"]
