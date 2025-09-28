#!/bin/bash
#
# start.sh : Jenkins 2.529 실행 스크립트
# - Java: /opt/azul/java/java (JAVA_HOME 환경변수에 이미 설정됨)
# - Jenkins 홈: /opt/jenkins/2.529/home
# - 로그 디렉토리: /opt/jenkins/2.529/logs
# - 포트: 8888
#

JENKINS_HOME="/opt/jenkins/2.529/home"
LOG_DIR="/opt/jenkins/2.529/logs"
JENKINS_WAR="/opt/jenkins/2.529/jenkins.war"   # war 파일 위치에 맞게 수정
JAVA_BIN="$JAVA_HOME/bin/java"
PID_FILE="$JENKINS_HOME/jenkins.pid"

# 디렉토리 준비
mkdir -p "$JENKINS_HOME" "$LOG_DIR"

echo "=== Jenkins Start Script ==="

# 1. 기존 Jenkins 프로세스 종료
if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
    echo "기존 Jenkins 프로세스 종료 중..."
    kill $(cat "$PID_FILE")
    sleep 5
    # 아직 살아있으면 강제 종료
    if ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
        echo "강제 종료..."
        kill -9 $(cat "$PID_FILE")
    fi
fi

# 2. Jenkins 실행
echo "Jenkins를 8888 포트에서 시작합니다..."
nohup "$JAVA_BIN" -DJENKINS_HOME="$JENKINS_HOME" \
     -jar "$JENKINS_WAR" --httpPort=8888 \
     >> "$LOG_DIR/jenkins.out" 2>> "$LOG_DIR/jenkins.err" &
JENKINS_PID=$!
echo $JENKINS_PID > "$PID_FILE"

echo "Jenkins PID: $JENKINS_PID"
echo "로그 위치: $LOG_DIR/jenkins.out 및 jenkins.err"
echo "=== Done ==="
