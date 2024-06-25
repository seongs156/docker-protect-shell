#!/usr/bin/env bash

STACK_ROOT=$( cd "$( dirname "$0" )" && pwd )
source "${STACK_ROOT}/scripts/util.sh"
# -------------------------------------------------------------------
# 사용자 계정 체크 : root 로 작업을 시작해야 합니다.
if [[ $EUID -ne 0 ]]; then
    abort "This must be run as root. (root 계정으로 실행해주세요.)"
fi

# echo
# outputQuestion "
# Docker Security Vulnerabilities Do you want to continue? (도커 보안 취약점 진행을 계속하시겠습니까?) [n/Y]"
# read -p " " -r
# if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#     abort
# fi

#### Main

# 도커 완전삭제
# sudo yum -y remove docker docker-common docker-selinux docker-engine docker-ce docker-ce-cli
# rm -rf /var/lib/docker


## 1. 도커 설치
# if ! command rpm -qa | grep docker-ce &> /dev/null; then
#     echo "Docker 설치중..."
#     sudo yum install -y yum-utils
#     sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#     sudo yum install -y docker-ce docker-ce-cli containerd.io
#     sudo systemctl enable docker
#     sudo systemctl start docker
#     sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#     sudo chmod +x /usr/local/bin/docker-compose
#     docker_version=$(docker version --format '{{.Server.Version}}')
#     echo "1. Docker is install. Version: $docker_version"
# else
#     docker_version=$(docker version --format '{{.Server.Version}}')
#     echo "Docker is installed. Version: $docker_version"
# fi



## 2. 도커 최신버전 패치
# docker_version=$(docker version --format '{{.Server.Version}}')
# rpm_docker_version=$(rpm -qa | grep docker-ce | awk -F'-' '/docker-ce-[0-9]/ {print $3}')

# if [ "$docker_version" != "$rpm_docker_version" ]; then
#     sudo yum update docker-ce docker-ce-cli containerd.io
#     sudo systemctl restart docker
#     docker_version=$(docker version --format '{{.Server.Version}}')
#     echo "2. Docker Update Version: $docker_version"
# fi



## 3. 도커 그룹에 불필요한 사용자 제거
# 도커그룹 사용자 확인 -> getent group docker
# 도커그룹 사용자 제거 ->  sudo gpasswd -d soluipx docker

## 3-1. soluipx 도커그룹 추가
# if ! command getent group docker | awk -F: '{print $4}' | grep -q "soluipx"; then
#     sudo usermod -aG docker soluipx
#     echo "3-1. Docker daemon audit 설정"
# fi

## 3-2. soluipx를 제외한 Docker그룹에 사용자 제거
# if ! [ "$(getent group docker | awk -F: '{print $4}')" = "soluipx" ]; then
#     sudo gpasswd -M soluipx docker
#     echo "3-2. Docker daemon audit 설정"
# fi

## 4. Docker daemon audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /usr/bin/docker &> /dev/null; then
    echo "-w /usr/bin/docker" >> /etc/audit/rules.d/audit.rules
    echo "4. Docker daemon audit 설정"
fi

## 5. /var/lib/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /var/lib/docker &> /dev/null; then
    echo "-w /var/lib/docker -k docker" >> /etc/audit/rules.d/audit.rules
    echo "5. /var/lib/docker audit 설정"
fi

## 6. /etc/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep  /etc/docker &> /dev/null; then
    echo "-w /etc/docker -k docker" >> /etc/audit/rules.d/audit.rules
    echo "6. /etc/docker audit 설정"
fi

## 7. docker.service audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /lib/systemd/system/docker.service &> /dev/null; then
    echo "-w /lib/systemd/system/docker.service -k docker" >> /etc/audit/rules.d/audit.rules
    echo "7. docker.service audit 설정"
fi

## 8. docker.socket audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /lib/systemd/system/docker.socket &> /dev/null; then
    echo "-w /lib/systemd/system/docker.socket -k docker" >> /etc/audit/rules.d/audit.rules
    echo "8. docker.socket audit 설정"
fi

## 9. /etc/default/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep  /etc/default/docker &> /dev/null; then
    echo "-w /etc/default/docker -k docker" >> /etc/audit/rules.d/audit.rules
    echo "9. /etc/default/docker audit 설정"
fi

service auditd restart