#!/usr/bin/env bash
# r10uvm137 — run pred137 over EVERY slang.uhdm in a verify_golden workdir and
# print the databases that can move, BY NAME.  MEASUREMENT ONLY.
#   usage: PRED=<pred137 binary> predsweep137.sh <workdir>
set -u
PRED=${PRED:?set PRED=<pred137 binary>}
WD=${1:?workdir}
n=0; fail=0; hit=0
while IFS= read -r f; do
  n=$((n+1))
  d=$(dirname "$f"); mode=$(basename "$(dirname "$d")"); name=$(basename "$d")
  out=$("$PRED" "$f" 2>/dev/null </dev/null); rc=$?
  [ $rc -eq 0 ] || { fail=$((fail+1)); echo "CENSUS-FAIL rc=$rc $mode/$name"; continue; }
  c=$(echo "$out" | sed -n 's/.*candidates=\([0-9]*\).*/\1/p')
  dp=$(echo "$out" | sed -n 's/.*dottedpaths=\([0-9]*\).*/\1/p')
  fe=$(echo "$out" | sed -n 's/.*foreach=\([0-9]*\).*/\1/p')
  if [ "${c:-0}" -gt 0 ]; then
    hit=$((hit+1))
    echo "CAN-MOVE $mode ${name%-*} candidates=$c dottedpaths=$dp foreach=$fe"
    echo "$out" | grep -a '^CAND' | sort | uniq -c | sed 's/^/    /'
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "SCANNED=$n CENSUS-FAIL=$fail CAN-MOVE=$hit"
