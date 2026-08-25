#!/usr/bin/env bash
# v92 verifier — FOUR producers: real Surelog golden, pristine, patched(as
# shipped), fixed(verified).  rc RECORDED for every child.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/v92_tools/ct92cen
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); D=$(readlink -f "$2"); mkdir -p "$D"; B=$(basename "$F")
cp "$F" "$D/"
EL=""; SEL=""
if [ "${ELAB:-0}" = 1 ]; then EL="-elabuhdm"; SEL="--elabuhdm"; fi
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv $EL -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
for pair in "o:/tmp/v92_bin/pristine.bin" "q:/tmp/v92_bin/patched.bin" "r:/tmp/v92_bin/fixed.bin"; do
  t=${pair%%:*}; bin=${pair#*:}
  ( cd "$D" && "$bin" "$B" $SEL -o $t.uhdm >$t.log 2>&1 </dev/null ); echo "$t rc=$?"
done
for t in g o q r; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q r; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
