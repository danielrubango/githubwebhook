#!/usr/bin/env bash

REPO='git@github.com:danielrubango/ledya.git';
RELEASE_DIR='/var/www/releases';
APP_DIR='/var/www/app';
RELEASE="release_`date +%Y%m%d%H%M%s`";

# Fetch Latest Code
[ -d $RELEASE_DIR ] || mkdir $RELEASE_DIR;
cd $RELEASE_DIR;
git clone -b master $REPO $RELEASE;

# Composer
cd $RELEASE_DIR/$RELEASE;
composer install --prefer-dist --no-scripts;
php artisan clear-compiled --env=production;
php artisan optimize --env=production;

# Symlinks
ln -nfs $RELEASE_DIR/$RELEASE $APP_DIR;
chgrp -h forge $APP_DIR;

## Env File
cd $RELEASE_DIR/$RELEASE;
ln -nfs ../../.env .env;
chgrp -h forge .env;

## Logs
rm -r $RELEASE_DIR/$RELEASE/storage/logs;
cd $RELEASE_DIR/$RELEASE/storage;
ln -nfs ../../../logs logs;
chgrp -h forge logs;

## Update Currente Site
ln -nfs $RELEASE_DIR/$RELEASE $APP_DIR;
chgrp -h forge $APP_DIR;

## PHP
sudo service php7.1-fpm reload;
