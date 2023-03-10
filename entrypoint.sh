#!/bin/bash

printf "Starting php-fpm7.4 daemon...\n"
php-fpm7.4 --daemonize || printf "Start php-fpm7.4 fail\n"

printf "Configure MySQL env...\n"
usermod -d /var/lib/mysql/ mysql || printf "usermod -d /var/lib/mysql/ mysql fail\n"
chown -R mysql:mysql /var/lib/mysql || printf "chown -R mysql:mysql /var/lib/mysqlfail\n"

printf "Starting MySQL...\n"
service mysql start || printf "Start MySQL fail\n"

printf "Set root MySQL pass, create DB Bitrix, create Bitrix DB user...\n"
echo "create user if not exists 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD';grant all privileges on *.* to 'root'@'%' with grant option;flush privileges;" | mysql #-p'$MYSQL_PASSWORD'
echo "set password for 'root'@'%' = '$MYSQL_ROOT_PASSWORD';" | mysql
echo "create database if not exists $MYSQL_DB_NAME;create user if not exists $MYSQL_USER_NAME identified by '$MYSQL_USER_PASSWORD';grant all privileges on $MYSQL_DB_NAME.* to $MYSQL_USER_NAME@'%' with grant option;flush privileges;" | mysql #-p'$MYSQL_PASSWORD'
echo "set password for $MYSQL_USER_NAME@'%' = '$MYSQL_USER_PASSWORD';" | mysql

printf "Starting Nginx...\n"
nginx -g 'daemon off;' || printf "Start Nginx fail\n"
