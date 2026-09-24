#!/bin/bash
# r11u136: the csv-level holes of scripts/compare_results.py, as synthetic
# controls. Each line: label, expected rc, a pattern the output must hold.
# Usage: gate_selftest.sh <repo>   (run it on the base scripts to see the holes)
set -u
R=${1:?repo}; T=$(mktemp -d /tmp/r11u136_gselftest.XXXX); fail=0
H='name,mode,status,detail,blocked_by,strict'
E='eq,default,CMP_EQUAL,,,equal'; S='sne,default,STRICT_NOTEQUAL,differ:line(3),,differ:line(3)'
N='ne,default,CMP_NOTEQUAL,x,,'; J='rej,default,SLANG_REJECT,y,,'
printf '%s\n' "$H" "$E" "$S" "$N" "$J" > $T/base.csv
chk() {  # <label> <want rc> <pattern> <fresh file> [extra args]
  local lab=$1 want=$2 pat=$3 f=$4; shift 4
  out=$(python3 $R/scripts/compare_results.py "$@" $f $T/base.csv 2>&1); rc=$?
  if [ $rc -eq $want ] && grep -q -- "$pat" <<<"$out"; then echo "ok   $lab (rc=$rc): $(grep -- "$pat" <<<"$out" | head -1)"
  else echo "FAIL $lab (rc=$rc want $want, pattern [$pat])"; echo "$out" | sed 's/^/     /' | head -8; fail=1; fi
}
w() { local f=$T/$1; shift; printf '%s\n' "$@" > $f; echo $f; }
chk 'G1 a row the run lost (no --filter) fails' 1 'REGRESSION ONLY-COMMITTED (not run) rej default SLANG_REJECT' $(w f1 "$H" "$E" "$S" "$N")
chk 'G2 a lost row inside --filter fails' 1 'REGRESSION ONLY-COMMITTED (not run) rej default' $(w f2 "$H" "$E" "$S" "$N") --filter '^(eq|rej)$'
chk 'G3 rows outside --filter are not expected' 0 'regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0' $(w f3 "$H" "$E") --filter '^eq$'
chk 'G4 a harness-mode row (thread exception) fails' 1 'REGRESSION HARNESS rej SURELOG_FAIL' $(w f4 "$H" "$E" "$S" "$N" 'rej,harness,SURELOG_FAIL,[Errno 13] Permission denied,,')
chk 'G5 an empty fresh csv (header only) fails' 1 'only-committed=4' $(w f5 "$H")
chk 'G6 a 0-byte fresh csv fails' 1 'only-committed=4' $(w f6 '')
chk 'G7 a key listed twice in the fresh csv fails' 1 'REGRESSION DUPLICATE ne default' $(w f7 "$H" "$E" "$S" 'ne,default,SLANG_REJECT,z,,' "$N" "$J")
chk 'G8 a default-only run against the both-modes baseline, --modes default' 0 'regressions=0' $(w f8 "$H" "$E" "$S" "$N" "$J") --modes default
printf '%s\r\n' "$H" "$E" "$S" "$N" "$J" > $T/f9
chk 'G9 CRLF fresh csv reads the same' 0 'regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0' $T/f9
chk 'G10 a malformed row exits 1' 1 'IndexError\|Traceback' $(w f10 "$H" "$E" 'sne,default')
# the probe shape: BOM, duplicate baseline case, a lost case
P='case,status,detail,strict'
printf '%s\n' "$P" 'a/b,EQUAL,,equal' 'a/c,STRICT_NOTEQUAL,differ:depth(2),differ:depth(2)' > $T/pb.csv
printf '\xef\xbb\xbf%s\n' "$P" > $T/pf_bom.csv; printf '%s\n' 'a/b,STRICT_NOTEQUAL,differ:line(1),differ:line(1)' 'a/c,STRICT_NOTEQUAL,differ:depth(2),differ:depth(2)' >> $T/pf_bom.csv
out=$(python3 $R/scripts/compare_results.py $T/pf_bom.csv $T/pb.csv 2>&1); rc=$?
if [ $rc -eq 1 ] && grep -q 'REGRESSION a/b EQUAL -> STRICT_NOTEQUAL' <<<"$out"; then echo "ok   G11 a BOM on the fresh probe csv still reads the probe shape (rc=1)"; else echo "FAIL G11 BOM probe (rc=$rc)"; echo "$out" | sed 's/^/     /' | head -6; fail=1; fi
printf '%s\n' "$P" 'a/b,EQUAL,,equal' > $T/pf12.csv
out=$(python3 $R/scripts/compare_results.py $T/pf12.csv $T/pb.csv 2>&1); rc=$?
if [ $rc -eq 1 ] && grep -q 'REGRESSION ONLY-COMMITTED (not run) a/c' <<<"$out"; then echo "ok   G12 a probe case whose dut.sv vanished fails (rc=1)"; else echo "FAIL G12 lost probe case (rc=$rc)"; echo "$out" | sed 's/^/     /' | head -6; fail=1; fi
printf '%s\n' "$P" 'a/b,EQUAL,,equal' 'a/c,STRICT_NOTEQUAL,differ:depth(2),differ:depth(2)' 'a/b,STRICT_NOTEQUAL,differ:line(1),differ:line(1)' > $T/pb13.csv
printf '%s\n' "$P" 'a/b,STRICT_NOTEQUAL,differ:line(1),differ:line(1)' 'a/c,STRICT_NOTEQUAL,differ:depth(2),differ:depth(2)' > $T/pf13.csv
out=$(python3 $R/scripts/compare_results.py $T/pf13.csv $T/pb13.csv 2>&1); rc=$?
if [ $rc -eq 1 ] && grep -q 'REGRESSION DUPLICATE a/b probe' <<<"$out"; then echo "ok   G13 a case listed twice in the baseline fails (rc=1)"; else echo "FAIL G13 duplicate baseline case (rc=$rc)"; echo "$out" | sed 's/^/     /' | head -6; fail=1; fi
rm -rf $T
echo "GATE SELFTEST $([ $fail -eq 0 ] && echo PASS || echo FAIL)"; exit $fail
