#!/bin/bash
# grid.sh <cases dir> — every case dir (dut.sv or args) in both views with $VB/$PRISBIN (default pristine) and
# $VB/$LAWBIN (default law), and the law binary under $OFFSW (default R11U219_OFF=1).  One line per case-view:
# <case> P:<verdict> L:<verdict> OFF=pristine|OFF=DIFF bytes=same|moved rcP rcL.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export LAWBIN=${LAWBIN:-law} PRISBIN=${PRISBIN:-pristine} OFFSW=${OFFSW:-R11U219_OFF=1}
V() { awk '{ for (i=1;i<=NF;i++) if ($i ~ /^strict=/) { s=substr($i,8); if (s ~ /^STRICT_EQUAL/) print "EQUAL"; else print s } ; if ($3=="SURELOG_FAIL"||$3=="SLANG_FAIL") print $3 }' | head -1; }
one() { c=$1; el=$2
  p=$(EL=$el bash $HERE/case.sh $c P $VB/$PRISBIN 2>/dev/null); l=$(EL=$el bash $HERE/case.sh $c L $VB/$LAWBIN 2>/dev/null)
  o=$(EL=$el bash $HERE/case.sh $c O $VB/$LAWBIN $OFFSW 2>/dev/null)
  pm=$(echo "$p" | grep -o 'md5=[0-9a-f]*'); lm=$(echo "$l" | grep -o 'md5=[0-9a-f]*'); om=$(echo "$o" | grep -o 'md5=[0-9a-f]*')
  printf "%s\tP:%s\tL:%s\t%s\t%s\t%s\t%s\n" "$(echo "$p" | awk '{print $1}')" "$(echo "$p" | V)" "$(echo "$l" | V)" "$([ "$om" = "$pm" ] && echo OFF=pristine || echo OFF=DIFF)" "$([ "$lm" = "$pm" ] && echo bytes=same || echo bytes=moved)" "$(echo "$p" | grep -o 'rc=[0-9]*')" "$(echo "$l" | grep -o 'rc=[0-9]*')"; }
export -f one V; export HERE
find "$(realpath $1)" \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort
