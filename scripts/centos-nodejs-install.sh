#!/usr/bin/env bash

STACK_ROOT=$( dirname $( cd "$( dirname "$0" )" && pwd ) )
source "${STACK_ROOT}/scripts/util.sh"
source "${STACK_ROOT}/scripts/version.sh"

title "node-${NODE_VERSION} install.."

# NodeJS - download
if [ ! -f ${STACK_ROOT}/download/node-${NODE_VERSION}.tar.xz ]; then
  wget https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
  -O ${STACK_ROOT}/download/node-${NODE_VERSION}.tar.xz

  if [ ${?} != "0" ]; then
    abort "node-${NODE_VERSION} - download failed"
  fi
fi

# NodeJS - binary install
mkdir -p $HOME/IPX-Web/WAS_v2.0 \
&& cd ${STACK_ROOT}/download/ \
&& tar xJf node-${NODE_VERSION}.tar.xz \
&& mv node-v${NODE_VERSION}-linux-x64 $HOME/IPX-Web/WAS_v2.0/node-${NODE_VERSION}

if [ ${?} != "0" ]; then
  abort "node-${NODE_VERSION} - install failed"
else
  cd ${STACK_ROOT}/download/ \
  && rm -rf node-${NODE_VERSION}

  cd $HOME/IPX-Web/WAS_v2.0 \
  && rm -f node \
  && ln -s node-${NODE_VERSION} node
fi

# NodeJS - add PATH
sed -e '10aPATH=$PATH:/home/soluipx/IPX-Web/WAS_v2.0/node/bin' -i $HOME/.bash_profile
source $HOME/.bash_profile


# PM2 Module - install
# npm pack pm2
if [ -f ${STACK_ROOT}/conf/node/pm2-3.5.1.tgz ]; then
  /home/soluipx/IPX-Web/WAS_v2.0/node/bin/npm install --production -g ${STACK_ROOT}/conf/node/pm2-3.5.1.tgz
fi
