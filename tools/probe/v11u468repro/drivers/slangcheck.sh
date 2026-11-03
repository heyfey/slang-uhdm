#!/bin/bash
# slangcheck.sh <casedir>...: upstream slang (~/.local/bin/slang) on the case's sources, --single-unit; prints the real exit code
SL=$HOME/.local/bin/slang; [ -x "$SL" ] || { echo "no slang"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || continue
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  (cd "$c" && "$SL" $F --single-unit -q >/tmp/v11u468_slang.log 2>&1 </dev/null); rc=$?
  echo "${c#*/cases/} slang_rc=$rc $(grep -m1 error: /tmp/v11u468_slang.log)"
done
