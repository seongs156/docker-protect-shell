#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
. "${STACK_ROOT}/scripts/util.sh"

title "Apache-PHP Configuration ..."

# PHP Custom setting
infomsg "Custom setting for PHP ..."
if [ ! -f $HOME/IPX-Web/WAS_v2.0/php/etc.d/php-custom.ini ]; then
  mkdir -p $HOME/IPX-Web/WAS_v2.0/php/etc.d
  cp -a "${STACK_ROOT}/conf/php/php-custom.ini" $HOME/IPX-Web/WAS_v2.0/php/etc.d/php-custom.ini
fi

# Apache Custom setting
infomsg "Custom setting for Apache ..."
if [ -f $HOME/IPX-Web/WAS_v2.0/httpd/bin/apachectl ]; then
  sed -e '2a\# chkconfig: 345 85 15' -i $HOME/IPX-Web/WAS_v2.0/httpd/bin/apachectl
  sed -e '3a\# description: init file for Apache2 server daemon' -i $HOME/IPX-Web/WAS_v2.0/httpd/bin/apachectl
  sed -e '4a\#' -i $HOME/IPX-Web/WAS_v2.0/httpd/bin/apachectl
fi

if [ -f $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf-org ]; then
  cp -a $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf-org $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
fi

if [ -f $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf ]; then
  sed -e 's/^\(ServerRoot.*\)/#\1\
Define SRVROOT "\/home\/soluipx\/IPX-Web\/WAS_v2.0\/httpd"\
ServerRoot "${SRVROOT}"/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^\(Listen.*\)/#\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e '/php7_module/d' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^#\(LoadModule rewrite_module.*\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^#\(LoadModule ssl_module.*\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^#\(LoadModule socache_shmcb_module.*\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^#\(LoadModule macro_module.*\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^#\(LoadModule include_module.*\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^User daemon/User soluipx/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^Group daemon/Group soluipx/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^\(ServerAdmin.*\)/#\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e '/^#ServerName www.example.com/a\ServerName 127.0.0.1' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/Options Indexes FollowSymLinks/Options None/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/DirectoryIndex index.html/DirectoryIndex index.html index.htm index.php/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^\(ErrorLog.*\)/#\1\
ErrorLog "|${SRVROOT}\/bin\/rotatelogs logs\/error_%Y%m%d.log 86400 540"/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^    \(CustomLog.*\)/    #\1\
    CustomLog "|${SRVROOT}\/bin\/rotatelogs logs\/access_%Y%m%d.log 86400 540" common/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^    \(ScriptAlias \/cgi-bin\/.*\)/    #\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  #sed -e 's/\/home\/soluipx\/IPX-Web\/WAS_v2.0\/httpd-[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/${SRVROOT}/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf

  sed -e 's/^#\(Include conf\/extra\/httpd-default.conf\)/\1/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  sed -e 's/^ServerTokens Full/ServerTokens Prod/' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra/httpd-default.conf
  if ! grep -Fxq "TraceEnable Off" "$HOME/IPX-Web/WAS_v2.0/httpd/conf/extra/httpd-default.conf" ; then
  cat <<EOF >>$HOME/IPX-Web/WAS_v2.0/httpd/conf/extra/httpd-default.conf

#
# Allow TRACE method
#
# Set to "extended" to also reflect the request body (only for testing and
# diagnostic purposes).
#
# Set to one of:  On | Off | extended
#
TraceEnable Off
EOF

  fi

  if ! grep -Fxq "Include conf/extra-ex/httpd-php.conf" "$HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf" ; then
  cat <<EOF >>$HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf

#
# * IMPORTANT: Additional settings for custom php
#
Include conf/extra-ex/httpd-php.conf
EOF

  fi

  sed -e '/^<IfModule ssl_module>/a\Include conf/extra-ex/httpd-ssl-custom.conf' -i $HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf
  if ! grep -Fxq "Include conf/extra-ex/httpd-vhosts-wrapper.conf" "$HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf" ; then
  cat <<EOF >>$HOME/IPX-Web/WAS_v2.0/httpd/conf/httpd.conf

#
# * IMPORTANT: Additional settings for custom virtual host
#
Include conf/extra-ex/httpd-vhosts-macro.conf
Include conf/extra-ex.d/*.conf
EOF

  fi

  cp -ar "${STACK_ROOT}/conf/apache/extra-ex" $HOME/IPX-Web/WAS_v2.0/httpd/conf/
  cp -ar "${STACK_ROOT}/conf/apache/extra-ex.d" $HOME/IPX-Web/WAS_v2.0/httpd/conf/
  
fi


# Apache SSL
#infomsg "Custom setting for Apache SSL ..."
#cp -ar "${STACK_ROOT}/conf/apache/extra-ssl" $HOME/IPX-Web/WAS_v2.0/httpd/conf/ \
#&& ip -4 -o addr show | awk '{gsub(/\/.*/,"",$4); if ($4 != "127.0.0.1") print "IP." (i++ +2) " = " $4}' >> $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/openssl-custom.cnf \
#&& openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/server.key -out $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/server.crt -config $HOME/IPX-Web/WAS_v2.0/httpd/conf/extra-ssl/openssl-custom.cnf -extensions 'v3_req' > /dev/null 2>&1

# Apache systemd conf
#if [ -f $HOME/IPX-Web/WAS_v2.0/httpd/support-files/httpd.service ]; then
#  cp -ar "${STACK_ROOT}/conf/apache/support-files" $HOME/IPX-Web/WAS_v2.0/httpd/
#fi

# TEST WebPage
mkdir -p $HOME/IPX-Web/siteRoot/IPX-TESTwwwRoot
cat <<EOF >$HOME/IPX-Web/siteRoot/IPX-TESTwwwRoot/index.php
<?php
#
# * IMPORTANT: Testing web page. Remove IPX-TESTwwwRoot the test is complete!
#
phpinfo();
EOF
 
