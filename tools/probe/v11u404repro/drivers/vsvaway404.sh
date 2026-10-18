#!/bin/bash
# vsvaway404.sh <wdA> <wdB> <csvA> <csvB> <out> : for every sv-tests row DIFFERENT (or STRICT_NOTEQUAL) in BOTH
# sweeps, the golden-vs-ours normalised dump diff line counts of A and B (TOWARD / AWAY / SAME, B relative to A);
# identical normalised dumps are reported SAME without the diff. Jobs 3.
A=$1; B=$2; CA=$3; CB=$4; OUT=$5
: ${UHDM_DUMP:?}
python3 - "$CA" "$CB" > $OUT.list <<'PY'
import csv,sys
a={r['case']:r['status'] for r in csv.DictReader(open(sys.argv[1]))}
b={r['case']:r['status'] for r in csv.DictReader(open(sys.argv[2]))}
for k in sorted(a):
    if a[k] in ('DIFFERENT','STRICT_NOTEQUAL') and b.get(k)==a[k]: print(k)
PY
one() {
  t=$1; r=${t%.sv}
  ga=$A/svtests/work/$r/slpp_all/surelog.uhdm
  [ -f $ga ] || ga=$(grep -o 'cache hit [^)]*' $A/svtests/work/$r/cmds.txt 2>/dev/null | awk '{print $3}')/golden.uhdm
  oa=$A/svtests/work/$r/slang.uhdm; ob=$B/svtests/work/$r/slang.uhdm
  [ -f $ga ] && [ -f $oa ] && [ -f $ob ] || { echo "$t MISSING"; return; }
  n() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//g; s#/tmp/v11u404_wd[A-Z]/[^ ,]*/##g'; }
  s=/tmp/v11u404_svaway.$$.$RANDOM; n $oa > $s.a; n $ob > $s.b
  if cmp -s $s.a $s.b; then echo "$t SAME-BYTES"; rm -f $s.a $s.b; return; fi
  n $ga > $s.g; da=$(diff $s.g $s.a | grep -c '^[<>]'); db=$(diff $s.g $s.b | grep -c '^[<>]')
  v=SAME; [ $db -lt $da ] && v=TOWARD; [ $db -gt $da ] && v=AWAY
  echo "$t a=$da b=$db $v"; rm -f $s.a $s.b $s.g
}
export -f one; export A B UHDM_DUMP
xargs -a $OUT.list -P 3 -I{} bash -c 'one {}' > $OUT
awk '{print $NF}' $OUT | sort | uniq -c
