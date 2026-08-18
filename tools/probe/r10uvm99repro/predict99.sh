#!/usr/bin/env bash
# r10uvm99 — MEASUREMENT ONLY.  Name every (mode, test) that CAN move, from
# OUR PRISTINE databases only.  Usage: predict99.sh <verify_golden workdir>
set -u
W=${1:?workdir}; P=${PRED99:-/tmp/r10uvm99_pred99}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
tot=0; pred=0
while IFS= read -r db; do
  tot=$((tot+1))
  out=$("$P" "$db" 2>/dev/null)
  set -- $out
  if [ "${1:-}" = PRED ] && [ "${2:-0}" != 0 ]; then
    pred=$((pred+1)); echo "PRED $(dirname "${db#$W/}") listop=$2 inside=$3"
  fi
done < <(find "$W" -name "slang.uhdm" | sort)
echo "PREDICTED $pred / $tot databases"
