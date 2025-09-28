#!/usr/bin/env bash
# macOS용: EC2(Name=jenkins, running)의 Public IP를 찾아 /etc/hosts의 'jenkins' 라인을 갱신
set -euo pipefail

BACKUP_SUFFIX="$(date +'%Y%m%d-%H%M%S')"
HOSTS_FILE="/etc/hosts"


AWS_ARGS=(ec2 describe-instances
  --filters "Name=tag:Name,Values=jenkins" "Name=instance-state-name,Values=running"
  --query "sort_by(Reservations[].Instances[] | [?PublicIpAddress!=null], &LaunchTime)[-1].PublicIpAddress"
  --output text
)


echo "[INFO] EC2(Name=jenkins) 의 Public IP 조회 중..."
IP="$(aws "${AWS_ARGS[@]}" || true)"

if [[ -z "${IP}" || "${IP}" == "None" ]]; then
  echo "[ERROR] 실행 중(running)이며 Public IP가 있는 'jenkins' 인스턴스를 찾지 못했습니다."
  exit 2
fi

echo "[INFO] 발견된 Public IP: ${IP}"

# /etc/hosts 백업
echo "[INFO] /etc/hosts 백업 생성: ~/Downloads/hosts.bak.${BACKUP_SUFFIX}"
cp /etc/hosts ~/Downloads/hosts.bak.${BACKUP_SUFFIX}






# /etc/hosts 에 'jenkins' 라인이 이미 있는지 확인(주석 제외)
if grep -qE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts"; then
  echo "[INFO] 기존 'jenkins' 라인을 ${IP}로 갱신합니다."
  # macOS sed: -i '' (백업은 위에서 이미 생성)
   sudo sed -E -i '' -e "s/^([[:space:]]*)([0-9A-Fa-f:.]+)([[:space:]]+[^#]*[[:<:]]jenkins[[:>:]][^#]*)([[:space:]]*#.*)?$/\1${IP}\3\4/" /etc/hosts
else
  echo "[INFO] 'jenkins'에 Jenkins 라인이 없습니다."
fi

# 결과 표시
echo "[INFO] 적용된 /etc/hosts 의 'jenkins' 항목:"
grep -nE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts" || true

echo "[DONE] hosts 업데이트 완료."
