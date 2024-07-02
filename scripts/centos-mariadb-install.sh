#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/scripts/util.sh"
source "${STACK_ROOT}/scripts/version.sh"

title "mariadb-${DB_VERSION} install.."

# MariaDB - download
if [ ! -f ${STACK_ROOT}/download/mariadb-${DB_VERSION}.tar.gz ]; then
  wget http://ftp.kaist.ac.kr/mariadb/mariadb-${DB_VERSION}/bintar-linux-systemd-x86_64/mariadb-${DB_VERSION}-linux-systemd-x86_64.tar.gz \
  -O ${STACK_ROOT}/download/mariadb-${DB_VERSION}.tar.gz

  if [ ${?} != "0" ]; then
    abort "mariadb-${DB_VERSION} - download failed"
  fi
fi

# MariaDB - binary install
mkdir -p $HOME/IPX-Storage/DATABASE \
&& cd ${STACK_ROOT}/download/ \
&& tar zxf mariadb-${DB_VERSION}.tar.gz \
&& mv mariadb-${DB_VERSION}-linux-systemd-x86_64 $HOME/IPX-Storage/DATABASE/mariadb-${DB_VERSION}


if [ ${?} != "0" ]; then
  abort "mariadb-${DB_VERSION} - install failed"
else
  cd ${STACK_ROOT}/download/ \
  && rm -rf mariadb-${DB_VERSION}
  
  cd $HOME/IPX-Storage/DATABASE \
  && rm -f mariadb \
  && ln -s mariadb-${DB_VERSION} mariadb
fi

if [ ! -f $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf ]; then
  mkdir -p $HOME/IPX-Storage/DATABASE/mariadb/etc
  cp -a "${STACK_ROOT}/conf/mariadb/etc/my.cnf" $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf
fi

if [ ! -f $HOME/IPX-Storage/DATABASE/mariadb/etc.d/my-custom.cnf ]; then
  mkdir -p $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf.d
  cp -a "${STACK_ROOT}/conf/mariadb/etc/my.cnf.d/my-custom.cnf" $HOME/IPX-Storage/DATABASE/mariadb/etc/my.cnf.d/my-custom.cnf
fi

infomsg "Config : mysql_install_db"
$HOME/IPX-Storage/DATABASE/mariadb/scripts/mysql_install_db --defaults-file=/home/soluipx/IPX-Storage/DATABASE/mariadb/etc/my.cnf --basedir=/home/soluipx/IPX-Storage/DATABASE/mariadb --datadir=/home/soluipx/IPX-Storage/DATABASE/mariadb/data --skip-test-db --user=soluipx  > /dev/null 2>&1
