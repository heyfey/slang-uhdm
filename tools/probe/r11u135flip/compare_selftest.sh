#!/bin/bash
# Synthetic rows through scripts/compare_results.py: every rule of the strict
# order, with its expected label and exit status. Usage: compare_selftest.sh <repo>
set -u
R=${1:?repo}; T=$(mktemp -d /tmp/r11u135_selftest.XXXX); fail=0
H='name,mode,status,detail,blocked_by,strict'
base() { printf '%s\n' "$H" \
  'eq,default,CMP_EQUAL,,,equal' 'sne,default,STRICT_NOTEQUAL,differ:line(3),,differ:line(3)' \
  'ne,default,CMP_NOTEQUAL,x,,' 'rej,default,SLANG_REJECT,y,,' > $T/base.csv; }
run() {  # <label> <expected rc> <expected grep> <rows for the fresh csv...>
  local lab=$1 want=$2 pat=$3; shift 3
  base; { echo "$H"; printf '%s\n' "$@"; } > $T/fresh.csv
  out=$(python3 $R/scripts/compare_results.py $T/fresh.csv $T/base.csv); rc=$?
  if [ $rc -eq $want ] && grep -q -- "$pat" <<<"$out"; then echo "ok   $lab (rc=$rc): $(grep -- "$pat" <<<"$out" | head -1)"
  else echo "FAIL $lab (rc=$rc want $want, pattern [$pat])"; echo "$out" | sed 's/^/     /'; fail=1; fi
}
S='sne,default,STRICT_NOTEQUAL,differ:line(3),,differ:line(3)'
E='eq,default,CMP_EQUAL,,,equal'; N='ne,default,CMP_NOTEQUAL,x,,'; J='rej,default,SLANG_REJECT,y,,'
run 'unchanged'                 0 'regressions=0 conversions=0 changes=0' "$E" "$S" "$N" "$J"
run 'CMP_EQUAL -> STRICT_NOTEQUAL' 1 'REGRESSION eq default CMP_EQUAL -> STRICT_NOTEQUAL differ:file(1)' 'eq,default,STRICT_NOTEQUAL,differ:file(1),,differ:file(1)' "$S" "$N" "$J"
run 'CMP_EQUAL -> CMP_NOTEQUAL'    1 'REGRESSION eq default CMP_EQUAL -> CMP_NOTEQUAL' 'eq,default,CMP_NOTEQUAL,z,,' "$S" "$N" "$J"
run 'STRICT_NOTEQUAL -> CMP_NOTEQUAL' 1 'REGRESSION sne default STRICT_NOTEQUAL -> CMP_NOTEQUAL' "$E" 'sne,default,CMP_NOTEQUAL,z,,' "$N" "$J"
run 'STRICT_NOTEQUAL -> SLANG_REJECT' 1 'REGRESSION sne default STRICT_NOTEQUAL -> SLANG_REJECT' "$E" 'sne,default,SLANG_REJECT,z,,' "$N" "$J"
run 'STRICT_NOTEQUAL -> CMP_EQUAL (conversion)' 0 'CONVERSION sne default STRICT_NOTEQUAL differ:line(3) -> CMP_EQUAL' "$E" 'sne,default,CMP_EQUAL,,,equal' "$N" "$J"
run 'CMP_NOTEQUAL -> CMP_EQUAL (conversion)' 0 'CONVERSION ne default CMP_NOTEQUAL -> CMP_EQUAL' "$E" "$S" 'ne,default,CMP_EQUAL,,,equal' "$J"
run 'verdict grows, same field' 0 'CHANGE sne default STRICT_NOTEQUAL differ:line(3) -> differ:line(5) \[line +2\]' "$E" 'sne,default,STRICT_NOTEQUAL,differ:line(5),,differ:line(5)' "$N" "$J"
run 'verdict shrinks, same field' 0 'CHANGE sne default STRICT_NOTEQUAL differ:line(3) -> differ:line(1) \[line -2\]' "$E" 'sne,default,STRICT_NOTEQUAL,differ:line(1),,differ:line(1)' "$N" "$J"
run 'verdict changes field' 0 'CHANGE sne default STRICT_NOTEQUAL differ:line(3) -> differ:fullname(2)$' "$E" 'sne,default,STRICT_NOTEQUAL,differ:fullname(2),,differ:fullname(2)' "$N" "$J"
run 'CMP_NOTEQUAL -> STRICT_NOTEQUAL (change)' 0 'CHANGE ne default CMP_NOTEQUAL -> STRICT_NOTEQUAL differ:type(1)' "$E" "$S" 'ne,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)' "$J"
run 'only-fresh CMP_EQUAL passes' 0 'ONLY-FRESH new default CMP_EQUAL equal' "$E" "$S" "$N" "$J" 'new,default,CMP_EQUAL,,,equal'
run 'only-fresh STRICT_NOTEQUAL fails' 1 'REGRESSION ONLY-FRESH (not equal) new default STRICT_NOTEQUAL differ:col(1)' "$E" "$S" "$N" "$J" 'new,default,STRICT_NOTEQUAL,differ:col(1),,differ:col(1)'
run 'only-fresh SLANG_REJECT fails' 1 'regressions=1' "$E" "$S" "$N" "$J" 'new,default,SLANG_REJECT,q,,'
run 'only-committed (filter) passes' 0 'ONLY-COMMITTED rej default SLANG_REJECT' "$E" "$S" "$N"
# the probe shape
printf 'case,status,detail,strict\na/b,EQUAL,,equal\na/c,STRICT_NOTEQUAL,differ:depth(2),differ:depth(2)\n' > $T/pb.csv
printf 'case,status,detail,strict\na/b,STRICT_NOTEQUAL,differ:line(1),differ:line(1)\na/c,STRICT_NOTEQUAL,differ:depth(4),differ:depth(4)\na/d,EQUAL,,equal\n' > $T/pf.csv
out=$(python3 $R/scripts/compare_results.py $T/pf.csv $T/pb.csv); rc=$?
if [ $rc -eq 1 ] && grep -q 'REGRESSION a/b EQUAL -> STRICT_NOTEQUAL differ:line(1)' <<<"$out" \
   && grep -q 'CHANGE a/c STRICT_NOTEQUAL differ:depth(2) -> differ:depth(4) \[depth +2\]' <<<"$out" \
   && grep -q 'ONLY-FRESH a/d EQUAL equal' <<<"$out" && grep -q '^\[probe\] EQUAL=1 STRICT_NOTEQUAL=2' <<<"$out"
then echo "ok   probe shape (rc=1): regression, change with delta, only-fresh EQUAL"; else echo "FAIL probe shape"; echo "$out"; fail=1; fi
rm -rf $T
echo "SELFTEST $([ $fail -eq 0 ] && echo PASS || echo FAIL)"; exit $fail
