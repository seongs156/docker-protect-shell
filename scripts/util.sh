#!/usr/bin/env bash

VERSION="0.9.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NO_COLOR='\033[0m'

outputInfo()
{
  printf "${GREEN}${1}${NO_COLOR}"
}

outputComment()
{
  printf "${YELLOW}${1}${NO_COLOR}"
}

outputQuestion()
{
  printf "\033[30;46m${1}${NO_COLOR}"
}

outputError()
{
  printf "\033[0;41m${1}${NO_COLOR}"
}

abort()
{
  if [ ! "${@}" = "" ]; then
    echo
    outputError "${@}"
    echo
  fi
  echo
  outputError "Exiting installer. (종료합니다.)"
  echo
  exit 1
}

title()
{
  echo
  outputComment "### $@ ###"
  echo
  echo
}

notice()
{
  echo
  outputInfo "Notice) $@"
  echo
  echo
}

error()
{
  echo
  outputError "Error) $@"
  echo
  echo
}

infomsg()
{
  outputInfo "$@"
  echo
}

infowarn()
{
  outputError "$@"
  echo
}

cmd()
{
  #printf "${GREEN}run# ${1}${NO_COLOR}\n"
  eval ${1}
  CMD_EXIT_CODE=${?}
  if [ ${CMD_EXIT_CODE} != "0" ]; then
    outputError "다음 명령이 실패하여, 설치가 중단되었습니다. (exit code: ${CMD_EXIT_CODE})"
    printf "\n"
    outputError "# ${1}"
    printf "\n"
    exit 1
  fi
}

help()
{
    echo "Usage : $0 -c [command]"
    echo
    echo "Options"
    echo "  -c install      Install APM(Apache, PHP, MariaDB)"
    echo "     uninstall    Uninstall APM(Apache, PHP, MariaDB)"
    echo 
}

rpmcheck()
{
  infomsg "Check package"
  line_str='........................'
  exit_code=0
  for rpm in make gcc gcc-c++ automake bison cmake libtool wget unzip curl telnet expat expat-devel freetype freetype-devel gd libcurl libcurl-devel libjpeg libjpeg-turbo-devel libpng libpng-devel libtiff libtiff-devel libxml2 libxml2-devel libxslt libxslt-devel ncurses ncurses-devel openssl openssl-devel pcre pcre-devel sqlite sqlite-devel zlib zlib-devel 
  do
    printf "    %s %s"  "$rpm" "${line_str:${#rpm}}"
    rpm -qa | grep "^$rpm-" > /dev/null
    if [ $? -eq 0 ]; then
      echo " yes"
    else
      exit_code=1
      echo " no (run as root: yum install $rpm)"
    fi
  done
  echo 
  if [ $exit_code -eq 1 ]; then
    abort "All package is necessary!!!"
  fi
  echo
}


