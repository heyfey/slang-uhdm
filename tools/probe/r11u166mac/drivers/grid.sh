#!/bin/bash
# grid.sh <tag=binary> ...   — every case under ../cases (dirs holding dut.sv), each binary: uhdm-cmp line count,
#   strictcmp verdict and objects differing; one line per case.  Env as case.sh (R166_SCRATCH, SURELOG, UHDM_CMP,
#   STRICT_CMP, UHDM_DUMP).  Extra env passes through to the binaries (switch runs).
set -u
here=$(cd "$(dirname "$0")" && pwd)
cd "$here/../cases"
find . -name dut.sv | sort | while read -r f; do
  d=$(dirname "$f"); line="$d"
  for tb in "$@"; do
    tag=${tb%%=*}; bin=${tb#*=}
    out=$(bash "$here/case.sh" "$d" "$bin" "$tag" 2>&1)
    w=$(echo "$out" | sed 's/.*\[//;s/\]//')
    v=$(echo "$out" | awk '{for(i=1;i<=NF;i++) if($i ~ /^STRICT_|^cmp=|^rc=/) printf "%s ", $i}')
    n=$("$STRICT_CMP" --max 0 "$w/golden.uhdm" "$w/$tag.uhdm" 2>&1 | grep -o 'objects_differing=[0-9]*' | cut -d= -f2)
    line="$line | $tag: $v n=${n:-0}"
  done
  echo "$line"
done
