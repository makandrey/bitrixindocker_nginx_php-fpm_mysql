FROM ubuntu:20.04
LABEL MAINTAINER="Andrey Makarov <an.makarov@krastsvetmet.ru>"

ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_ROOT_PASSWORD=123QWErty456
ENV MYSQL_USER_NAME=bitrix
ENV MYSQL_USER_PASSWORD=321qweRTY654
ENV MYSQL_DB_NAME=bitrix

RUN apt -qq update && \
    apt install -y \
    mysql-server \
    #mariadb-server-10.3 \
    nginx \
    php7.4-common \
    php7.4-readline \
    php7.4-fpm \
    php7.4-cli \
    php7.4-gd \
    php7.4-mysql \
    php7.4-curl \
    php7.4-mbstring \
    php7.4-opcache \
    php7.4-json \
    php7.4-xml \
    php7.4-zip \
    && rm -rf /var/lib/apt/lists/*

RUN rm -R /var/www/html/* && \
    rm -R /etc/nginx/sites-available/* && \
    rm -R /etc/nginx/sites-enabled/*

#COPY ./www /var/www/html/
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/default /etc/nginx/sites-available/default 
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
COPY ./php/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./php/php.ini etc/php/7.4/fpm/php.ini

COPY ./php/mods-available/* /etc/php/7.4/mods-available/
RUN ln -s /etc/php/7.4/mods-available/apcu.ini /etc/php/7.4/fpm/conf.d/apcu.ini && \
    ln -s /etc/php/7.4/mods-available/bitrixenv.ini /etc/php/7.4/fpm/conf.d/bitrixenv.ini && \
    ln -s /etc/php/7.4/mods-available/opcache.ini /etc/php/7.4/fpm/conf.d/opcache.ini

RUN mkdir -p /tmp/php_sessions/www && \
    chown www-data:www-data /tmp/php_sessions/www

COPY ./mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html

COPY ./nginx/ssl/bitrix.crt /etc/ssl/certs/bitrix.crt
COPY ./nginx/ssl/bitrix.key /etc/ssl/private/bitrix.key

COPY /entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
