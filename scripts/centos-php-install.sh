#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
. "${STACK_ROOT}/scripts/util.sh"
. "${STACK_ROOT}/scripts/version.sh"

title "php-${PHP_VERSION} install.."

# PHP - download
if [ ! -f ${STACK_ROOT}/download/php-${PHP_VERSION}.tar.gz ]; then
  wget http://php.net/distributions/php-${PHP_VERSION}.tar.gz -O ${STACK_ROOT}/download/php-${PHP_VERSION}.tar.gz

  if [ ${?} != "0" ]; then
    abort "php-${PHP_VERSION} - download failed"
  fi
fi

# PHP - compile install
mkdir -p $HOME/IPX-Web/WAS_v2.0 \
&& cd ${STACK_ROOT}/download/ \
&& rm -rf php-${PHP_VERSION} \
&& tar zxf php-${PHP_VERSION}.tar.gz \
&& cd php-${PHP_VERSION} \
&& ./configure \
--prefix=$HOME/IPX-Web/WAS_v2.0/php-${PHP_VERSION} \
--with-config-file-path=$HOME/IPX-Web/WAS_v2.0/php-${PHP_VERSION}/php.ini \
--with-config-file-scan-dir=$HOME/IPX-Web/WAS_v2.0/php-${PHP_VERSION}/etc.d \
--with-apxs2=$HOME/IPX-Web/WAS_v2.0/httpd/bin/apxs \
--with-libdir=lib64 \
--with-mysql-sock \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-jpeg \
--with-openssl \
--with-openssl-dir \
--with-zlib \
--with-zip \
--with-curl \
--enable-gd \
--enable-zip \
--enable-mbstring \
--enable-mbregex \
--enable-maintainer-zts \
&& make -j4 \
&& make -j4 install


if [ ${?} != "0" ]; then
  abort "php-${PHP_VERSION} - install failed"
else
  if [ ! -f $HOME/IPX-Web/WAS_v2.0/php-${PHP_VERSION}/php.ini ]; then
    cd ${STACK_ROOT}/download/php-${PHP_VERSION} \
    && cp -a php.ini-production $HOME/IPX-Web/WAS_v2.0/php-${PHP_VERSION}/php.ini
  fi

  cd ${STACK_ROOT}/download/ \
  && rm -rf php-${PHP_VERSION}
  
  cd $HOME/IPX-Web/WAS_v2.0 \
  && rm -f php \
  && ln -s php-${PHP_VERSION} php
fi
