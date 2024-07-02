#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )

echo "${STACK_ROOT}"

. "${STACK_ROOT}/scripts/util.sh"
. "${STACK_ROOT}/scripts/version.sh"

title "httpd-${HTTPD_VERSION} install.."

# Apache - download
if [ ! -f ${STACK_ROOT}/download/httpd-${HTTPD_VERSION}.tar.gz ]; then
  wget http://archive.apache.org/dist/httpd/httpd-${HTTPD_VERSION}.tar.gz -O ${STACK_ROOT}/download/httpd-${HTTPD_VERSION}.tar.gz

  if [ ${?} != "0" ]; then
    abort "httpd-${HTTPD_VERSION} - download failed"
  fi
fi

# Apr - download
if [ ! -f ${STACK_ROOT}/download/apr-1.7.0.tar.gz ]; then
  wget https://archive.apache.org/dist/apr/apr-1.7.0.tar.gz -O ${STACK_ROOT}/download/apr-1.7.0.tar.gz

  if [ ${?} != "0" ]; then
    abort "apr-1.7.0 - download failed"
  fi
fi

# Apr-util - download
if [ ! -f ${STACK_ROOT}/download/apr-util-1.6.1.tar.gz ]; then
  wget https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz -O ${STACK_ROOT}/download/apr-util-1.6.1.tar.gz

  if [ ${?} != "0" ]; then
    abort "apr-util-1.6.1 - download failed"
  fi
fi

# Apache - compile install
mkdir -p $HOME/IPX-Web/WAS_v2.0 \
&& cd ${STACK_ROOT}/download/ \
&& rm -rf httpd-${HTTPD_VERSION} \
&& tar zxf httpd-${HTTPD_VERSION}.tar.gz \
&& tar zxf apr-1.7.0.tar.gz -C httpd-${HTTPD_VERSION}/srclib/ \
&& mv httpd-${HTTPD_VERSION}/srclib/apr-1.7.0 httpd-${HTTPD_VERSION}/srclib/apr  \
&& tar zxf apr-util-1.6.1.tar.gz -C httpd-${HTTPD_VERSION}/srclib/ \
&& mv httpd-${HTTPD_VERSION}/srclib/apr-util-1.6.1 httpd-${HTTPD_VERSION}/srclib/apr-util  \
&& cd httpd-${HTTPD_VERSION} \
&& ./configure -C \
--prefix=$HOME/IPX-Web/WAS_v2.0/httpd-${HTTPD_VERSION} \
--with-included-apr \
--with-included-apr-util \
--with-pcre \
--with-ssl \
--enable-mods-shared=ssl \
--enable-ssl \
--enable-module=so \
--enable-so \
--enable-rule=SHARED_CORE \
--enable-rewrite \
--enable-ssl=shared \
&& make -j4 \
&& make -j4 install


if [ ${?} != "0" ]; then
  abort "httpd-${HTTPD_VERSION} - install failed"
else
  if [ ! -f $HOME/IPX-Web/WAS_v2.0/httpd-${HTTPD_VERSION}/conf/httpd.conf-org ]; then
    cp -a $HOME/IPX-Web/WAS_v2.0/httpd-${HTTPD_VERSION}/conf/httpd.conf $HOME/IPX-Web/WAS_v2.0/httpd-${HTTPD_VERSION}/conf/httpd.conf-org
  fi

  cd ${STACK_ROOT}/download/ \
  && rm -rf httpd-${HTTPD_VERSION}
  
  cd $HOME/IPX-Web/WAS_v2.0 \
  && rm -f httpd \
  && ln -s httpd-${HTTPD_VERSION} httpd
fi

chmod 700 $HOME/IPX-Web/WAS_v2.0/httpd/bin/apachectl
