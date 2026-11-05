#!/usr/bin/env bash
# grid.sh <binary> <workroot> <case dir>...  — one verdict line per case:
# <case> rc=<slang rc> cmp=<PASS_CMP|CMP_FAIL> strict=<last strictcmp line> dumpdiff=<lines>
# Golden first (LHS = Surelog), ours second (RHS).
ROOT=$(cd "$(dirname "$(realpath "$0")")/../../../.." && pwd)
BIN=$1; WR=$2; shift 2
for c in "$@"; do
  n=$(basename "$c"); g=$(basename "$(dirname "$c")")
  W=$WR/$g/$n; rm -rf "$W"; mkdir -p "$W"
  out=$(SLANG_UHDM=$BIN WORK=$W "$ROOT/scripts/converge.sh" "$c/dut.sv" 2>&1)
  cmp=$(echo "$out" | grep -oE 'PASS_CMP|CMP_FAIL|SURELOG_FAIL|SLANG_FAIL' | head -1)
  dd=$(echo "$out" | grep -oE 'DUMP_DIFF [0-9]+' | awk '{print $2}'); dd=${dd:-0}
  st=-
  [ -f "$W/slang.uhdm" ] && [ -f "$W/slpp_all/surelog.uhdm" ] && \
    st=$("$ROOT/build/uhdm-strictcmp" "$W/slpp_all/surelog.uhdm" "$W/slang.uhdm" 2>&1 | tail -n 1)
  echo "$g/$n cmp=$cmp strict=$st dumpdiff=$dd"
done
