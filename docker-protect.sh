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


# ## 1. 도커 설치
if ! command rpm -qa | grep docker-ce &> /dev/null; then
    echo "Docker 설치중..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker_version=$(docker version --format '{{.Server.Version}}')
    echo "1. Docker is install. Version: $docker_version"
else
    docker_version=$(docker version --format '{{.Server.Version}}')
    echo "Docker is installed. Version: $docker_version"
fi



# ## 2. 도커 최신버전 패치
docker_version=$(docker version --format '{{.Server.Version}}')
rpm_docker_version=$(rpm -qa | grep docker-ce | awk -F'-' '/docker-ce-[0-9]/ {print $3}')

if [ "$docker_version" != "$rpm_docker_version" ]; then
    sudo yum update docker-ce docker-ce-cli containerd.io
    sudo systemctl restart docker
    docker_version=$(docker version --format '{{.Server.Version}}')
    echo "2. Docker Update Version: $docker_version"
fi



# ## 3. 도커 그룹에 불필요한 사용자 제거
# # 도커그룹 사용자 확인 -> getent group docker
# # 도커그룹 사용자 제거 ->  sudo gpasswd -d soluipx docker


### 3-1. soluipx 도커그룹 추가
if ! command getent group docker | awk -F: '{print $4}' | grep -q "soluipx"; then
    sudo usermod -aG docker soluipx
    echo "soluipx 도커그룹 추가"
fi


### 3-2. soluipx를 제외한 Docker그룹에 사용자 제거
if ! [ "$(getent group docker | awk -F: '{print $4}')" = "soluipx" ]; then
    sudo gpasswd -M soluipx docker
    echo "soluipx를 제외한 Docker그룹에 사용자 제거"
fi


### 4. Docker daemon audit 설정
auditd_flag=false
if ! command cat /etc/audit/rules.d/audit.rules | grep /usr/bin/docker &> /dev/null; then
    echo "Docker daemon audit 설정"
    auditd_flag=true
fi


### 5. /var/lib/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /var/lib/docker &> /dev/null; then
    echo "/var/lib/docker audit 설정"
    auditd_flag=true
fi


### 6. /etc/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep  /etc/docker &> /dev/null; then
    echo "/etc/docker audit 설정"
    auditd_flag=true
fi


### 7. docker.service audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /lib/systemd/system/docker.service &> /dev/null; then
    echo "docker.service audit 설정"
    auditd_flag=true
fi


### 8. docker.socket audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep /lib/systemd/system/docker.socket &> /dev/null; then
    echo "docker.socket audit 설정"
    auditd_flag=true
fi


### 9. /etc/default/docker audit 설정
if ! command cat /etc/audit/rules.d/audit.rules | grep  /etc/default/docker &> /dev/null; then
    echo "/etc/default/docker audit 설정"
    auditd_flag=true
fi

if [ "$auditd_flag" = true ]; then
    service auditd restart
fi


### 10. default bridege를 통한 컨테이너간 네트워크 트래픽 제한
if ! command docker network ls --quiet | xargs docker network inspect --format '{{.Name}}: {{ .Options }}' | grep com.docker.network.bridge.enable_icc:false &> /dev/null; then

    service docker stop &> /dev/null
    service docker.socket stop &> /dev/null
    service docker.service stop &> /dev/null

    if ! ls /etc/default/docker &> /dev/null; then
        touch /etc/default/docker
        echo "DOCKER_OPTS='--icc=false --selinux-enabled'" >> /etc/default/docker
    fi
    
    FILE='/lib/systemd/system/docker.service'
    # [Service] 부분의 행 번호 찾기
    ADD_LINE_NUMBER=$(($(grep -n "\[Service\]" $FILE | cut -d: -f1)+1))

    OLD_LINE='ExecStart=/usr/bin/dockerd'
    sudo sed -i "\|$OLD_LINE|d" $FILE

    NEW_LINE='EnvironmentFile=/etc/default/docker'
    if ! grep -q "$NEW_LINE" "$FILE"; then
        sudo sed -i "$((ADD_LINE_NUMBER + 1))i $NEW_LINE" $FILE
    fi

    NEW_LINE2="ExecStart=/usr/bin/dockerd -H fd:// \$DOCKER_OPTS"
    if ! grep -q "$NEW_LINE2" "$FILE"; then
        sudo sed -i "$((ADD_LINE_NUMBER + 2))i $NEW_LINE2" $FILE
    fi

    service docker start &> /dev/null
    service docker.socket start &> /dev/null
    service docker.service start &> /dev/null
    systemctl daemon-reload &> /dev/null
    echo "default bridege를 통한 컨테이너간 네트워크 트래픽 제한"
fi


### 11. 도커 클라이언트 인증 활성화
if [[ "$(docker plugin ls)" == *"ID        NAME      DESCRIPTION   ENABLED"* ]]; then
    # docker plugin ls
    # 플러그인 정지 -> sudo docker plugin disable vieux/sshfs:latest
    # 플러그인 삭제 -> sudo docker plugin rm vieux/sshfs:latest
    mkdir -p /var/lib/docker/plugins/
    docker plugin install --grant-all-permissions vieux/sshfs
    # 플러그인 ID 가져오기
    # PLUGIN_ID=$(sudo docker plugin ls | awk 'NR>1 {print $1}')

    # JSON 파일 업데이트
    # sudo jq '. + {"authorization-plugins": ["'$PLUGIN_ID'"]}' /etc/docker/daemon.json > tmp.$$.json && sudo mv tmp.$$.json /etc/docker/daemon.json
    # service docker restart
    # service docker.socket restart
    # service docker.service restart
    echo "도커 클라이언트 인증 활성화"
fi


### 12. docker.service 소유권 설정
if [ ! "$(stat -c '%U:%G' /lib/systemd/system/docker.service)" == "root:root" ]; then
    sudo chown root:root /lib/systemd/system/docker.service
    echo docker.service 소유권 설정
fi


### 13. docker.service 파일 접근권한 설정
SERVICE_PATH=$(systemctl show -p FragmentPath docker.service | awk -F= '{print $2}')
# 결과값이 있는지 확인
if [ -n "$SERVICE_PATH" ]; then
    PERMISSIONS=$(stat -c '%a' $SERVICE_PATH)
    if ! [ "$PERMISSIONS" == "644" ]; then
        chmod 644 $SERVICE_PATH
        echo docker.service 파일 접근권한 설정
    fi
fi


### 14. docker.socket 소유권 설정
SOCKET_PATH=$(systemctl show -p FragmentPath docker.socket | awk -F= '{print $2}')
# 결과값이 있는지 확인
if [ -n "$SOCKET_PATH" ]; then
    if [ ! "$(stat -c '%U:%G' $SOCKET_PATH)" == "root:root" ]; then
        chown root:root $SOCKET_PATH
        echo docker.socket 소유권 설정
    fi
fi


### 15. /etc/docker 디렉터리 소유권 설정
if [ ! "$(stat -c '%U:%G' /etc/docker)" == "root:root" ]; then
    sudo chown root:root /etc/docker
    echo /etc/docker 디렉터리 소유권 설정
fi


### 16. /etc/docker 디렉터리 접근권한 설정
ETC_DOCKER_DIR="/etc/docker"
if [ -d "$ETC_DOCKER_DIR" ]; then
    if [ "$(stat -c '%a' $ETC_DOCKER_DIR)" -gt 755 ]; then
        chmod 755 $ETC_DOCKER_DIR
        echo "/etc/docker 디렉터리 접근권한 설정"
    fi
fi


### 17. /var/run/docker.sock 파일 소유권 설정
if [ ! "$(stat -c '%U:%G' /var/run/docker.sock)" == "root:docker" ]; then
    sudo chown root:docker /var/run/docker.sock
    echo /var/run/docker.sock 파일 소유권 설정
fi


### 18. /var/run/docker.sock 파일 접근 권한 설정
DOCKER_SOCK="/var/run/docker.sock"
if ls $DOCKER_SOCK &> /dev/null; then
    if [ "$(stat -c '%a' $DOCKER_SOCK)" -gt 660 ]; then
        sudo chmod 660 $DOCKER_SOCK
        echo "/var/run/docker.sock 파일 접근 권한 설정"
    fi
fi

DAEMON_JSON="/etc/docker/daemon.json"
### 19. daemon.json 파일 소유권 설정
if ls $DAEMON_JSON &> /dev/null; then
    if [ ! "$(stat -c '%U:%G' $DAEMON_JSON)" == "root:root" ]; then
        sudo chown root:root $DAEMON_JSON
        echo daemon.json 파일 소유권 설정
    fi
fi

### 20. daemon.json 파일 접근권한 설정
if ls $DAEMON_JSON &> /dev/null; then
    if [ "$(stat -c '%a' $DAEMON_JSON)" -gt 644 ]; then
        sudo chmod 644 $DAEMON_JSON
        echo "/etc/docker 디렉터리 접근권한 설정"
    fi
fi


### 21. /etc/default/docker 파일 소유권 설정
if [ ! "$(stat -c '%U:%G' /etc/default/docker)" == "root:root" ]; then
    sudo chown root:root /etc/default/docker
    echo /etc/default/docker 파일 소유권 설정
fi


### 22. /etc/default/docker 파일 접근권한 설정
DEFAULT_DOCKER="/etc/default/docker"
if ls $DEFAULT_DOCKER &> /dev/null; then
    if [ "$(stat -c '%a' $DEFAULT_DOCKER)" -gt 644 ]; then
        sudo chmod 644 $DEFAULT_DOCKER
        echo "/etc/default/docker 파일 접근권한 설정"
    fi
fi


### 23. 도커를 위한 컨텐츠 신뢰성 활성화
if [ ! "$(echo $DOCKER_CONTENT_TRUST)" == "1" ]; then
    echo "도커를 위한 컨텐츠 신뢰성 활성화"
    echo "export DOCKER_CONTENT_TRUST=1" >> ~/.bashrc
    sudo source ~/.bashrc
fi


### 24. 컨테이너 SELinux 보안 옵션 설정
FILE="/etc/default/docker"
OPTION="--selinux-enabled"
if ! grep -q "selinux-enabled" "$FILE"; then
    service docker stop &> /dev/null
    service docker.socket stop &> /dev/null
    service docker.service stop &> /dev/null

    if ! ls /etc/default/docker &> /dev/null; then
        touch /etc/default/docker
        echo "DOCKER_OPTS='--icc=false --selinux-enabled'" >> /etc/default/docker
    fi

    sudo sed -i "/^DOCKER_OPTS=/ s/'$/ $OPTION'/" "$FILE" || echo "DOCKER_OPTS='--icc=false $OPTION'" | sudo tee -a "$FILE"

    SERVICE_FILE='/lib/systemd/system/docker.service'
    # [Service] 부분의 행 번호 찾기
    ADD_LINE_NUMBER=$(($(grep -n "\[Service\]" $SERVICE_FILE | cut -d: -f1)+1))

    OLD_LINE='ExecStart=/usr/bin/dockerd'
    sudo sed -i "\|$OLD_LINE|d" $SERVICE_FILE

    NEW_LINE='EnvironmentFile=/etc/default/docker'
    if ! grep -q "$NEW_LINE" "$SERVICE_FILE"; then
        sudo sed -i "$((ADD_LINE_NUMBER + 1))i $NEW_LINE" $SERVICE_FILE
    fi

    NEW_LINE2="ExecStart=/usr/bin/dockerd -H fd:// \$DOCKER_OPTS"
    if ! grep -q "$NEW_LINE2" "$SERVICE_FILE"; then
        sudo sed -i "$((ADD_LINE_NUMBER + 2))i $NEW_LINE2" $SERVICE_FILE
    fi

    service docker start &> /dev/null
    service docker.socket start &> /dev/null
    service docker.service start &> /dev/null
    systemctl daemon-reload &> /dev/null
    echo "컨테이너 SELinux 보안 옵션 설정"
fi


### 25. 컨테이너에서 ssh 사용 금지
# 컨테이너에서 설정
# docker ps --quiet
# docker exec <컨테이너 ID> ps -el


### 26. 컨테이너에 privileged 포트 매핑 금지
# 컨테이너에서 설정


### 27. PIDs cgroup 제한
# docker-compose.yml 파일에 작성


### 28. 도커의 default bridge docker() 사용 제한
# 10번과 동일함 


### 29. 호스트의 user namespaces 공유 제한
# 컨테이너에서 설정
