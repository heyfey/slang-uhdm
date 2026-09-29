#!/bin/bash
# r11u220repro: judge every case dir under cases/ (dut.sv, or an `args` file) in both views (EL=0 the parse form, EL=1
# --elabuhdm / -elabuhdm) with the pristine binary ($B/$PRISBIN) and the law binary ($B/$LAWBIN), one line per
# case-view: <case> P:<verdict> L:<verdict> OFF=pristine|OFF=DIFF (the law binary under R11U220_OFF=1 byte-compared
# with the pristine one). Uses case.sh (fence fail-closed). usage: grid.sh [subdir] > grid.tsv
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export LAWBIN=${LAWBIN:-law.bin} PRISBIN=${PRISBIN:-pristine.bin}
V() { awk '{ for (i=1;i<=NF;i++) if ($i ~ /^strict=/) { s=substr($i,8); if (s ~ /^STRICT_EQUAL/) print "EQUAL"; else print s } ; if ($3=="SURELOG_FAIL"||$3=="SLANG_FAIL") print $3 }' | head -1; }
one() { c=$1; el=$2
  p=$(EL=$el bash $HERE/case.sh $c P $B/$PRISBIN 2>/dev/null); l=$(EL=$el bash $HERE/case.sh $c L $B/$LAWBIN 2>/dev/null)
  o=$(EL=$el bash $HERE/case.sh $c O $B/$LAWBIN R11U220_OFF=1 2>/dev/null)
  pm=$(echo "$p" | grep -o 'md5=[0-9a-f]*'); lm=$(echo "$l" | grep -o 'md5=[0-9a-f]*'); om=$(echo "$o" | grep -o 'md5=[0-9a-f]*')
  printf "%s\tP:%s\tL:%s\t%s\t%s\n" "$(echo "$p" | awk '{print $1}')" "$(echo "$p" | V)" "$(echo "$l" | V)" "$([ "$om" = "$pm" ] && echo OFF=pristine || echo OFF=DIFF)" "$([ "$lm" = "$pm" ] && echo bytes=same || echo bytes=moved)"; }
export -f one V; export HERE
find $HERE/../cases/${1:-} \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort
