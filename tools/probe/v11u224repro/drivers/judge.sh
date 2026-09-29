#!/bin/bash
# v11u224: judge byte movers. judge.sh <file of "dir el" lines> > out.tsv: per case-view, golden (case.sh), P and L
# verdicts and the chain-keyed / dump away census (caseaway.py). Fail-closed on $FENCED (env.sh, case.sh).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
V() { awk '{ if ($3=="SURELOG_FAIL"||$3=="SLANG_FAIL") { print $3; exit } c=""; s=""; for (i=1;i<=NF;i++) { if ($i ~ /^cmp=/) c=substr($i,5); if ($i ~ /^strict=/) s=substr($i,8) } ; if (c!="0") print "STAGE1(cmp=" c ")"; else if (s ~ /^STRICT_EQUAL/) print "EQUAL"; else print s }' | head -1; }
one() { c=$1; el=$2
  p=$(EL=$el bash $HERE/case.sh $c P $B/pristine.bin 2>/dev/null); l=$(EL=$el bash $HERE/case.sh $c L $B/${LAWBIN:-law.bin} 2>/dev/null)
  rel=$(echo "$p" | awk '{print $1}'); pv=$(echo "$p" | V); lv=$(echo "$l" | V)
  pm=$(echo "$p" | grep -o 'md5=[0-9a-f]*'); lm=$(echo "$l" | grep -o 'md5=[0-9a-f]*')
  a="-"; if [ "$pm" != "$lm" ] && [ "$pv" != SURELOG_FAIL ] && [ "$pv" != SLANG_FAIL ]; then a=$(python3 $HERE/caseaway.py $S/g/$rel P L 2>&1 | cut -d' ' -f2-); fi
  printf "%s\tP:%s\tL:%s\t%s\t%s\n" "$rel" "$pv" "$lv" "$([ "$pm" = "$lm" ] && echo bytes=same || echo bytes=moved)" "$a"; }
export -f one V; export HERE
cat ${1:?list} | xargs -P${GRIDJ:-3} -L1 bash -c 'one $0 $1' | sort
