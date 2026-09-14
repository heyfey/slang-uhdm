#!/usr/bin/env bash
# r11u30 — MEASUREMENT ONLY.  Name every (mode, test) whose database CAN move
# under § insideOpenRangeMemberIsOneListOp30, from OUR PRISTINE databases only.
#   usage: predict30.sh <verify_golden workdir> [gapMax]
set -u
W=${1:?workdir}; G=${2:-2}; P=${PRED30:-/tmp/r11u30_pred30}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
tot=0; pred=0; withins=0
while IFS= read -r db; do
  tot=$((tot+1))
  out=$("$P" "$db" "$G" 2>/dev/null)
  set -- $out
  [ "${1:-}" = PRED ] || { echo "UNREADABLE $(dirname "${db#$W/}")"; continue; }
  [ "${3:-0}" != 0 ] && withins=$((withins+1))
  if [ "${2:-0}" != 0 ]; then
    pred=$((pred+1)); echo "PRED $(dirname "${db#$W/}") movable=$2 exprinside=$3 inside=$4"
  fi
done < <(find "$W" -name "slang.uhdm" | sort)
echo "PREDICTED $pred / $tot databases ($withins carry an expression-inside at all)"
