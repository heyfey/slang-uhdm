#!/bin/bash
# v11u224repro (adapted from r11u224repro/drivers/grid.sh): judge every case dir under the given root (dut.sv or an
# `args` file) in both views (EL=0 parse, EL=1 --elabuhdm / -elabuhdm) with $B/pristine.bin (P) and $B/$LAWBIN (L),
# plus L under R11U224_OFF=1 (O) byte-compared with P. One line per case-view:
# <case> P:<cmp>/<strict> L:<cmp>/<strict> OFF=pristine|OFF=DIFF bytes=same|moved rcP rcL
# usage: grid.sh <root dir> > grid.tsv   (or LIST=<file of case dirs> grid.sh -)    (fence fail-closed via env.sh / case.sh)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export LAWBIN=${LAWBIN:-law.bin} PRISBIN=${PRISBIN:-pristine.bin}
V() { awk '{ if ($3=="SURELOG_FAIL"||$3=="SLANG_FAIL") { print $3; exit } c=""; s=""; for (i=1;i<=NF;i++) { if ($i ~ /^cmp=/) c=substr($i,5); if ($i ~ /^strict=/) s=substr($i,8) } ; if (c!="0") print "STAGE1(cmp=" c ")"; else if (s ~ /^STRICT_EQUAL/) print "EQUAL"; else print s }' | head -1; }
R() { grep -o 'rc=[0-9]*' | tail -1; }
one() { c=$1; el=$2
  p=$(EL=$el bash $HERE/case.sh $c P $B/$PRISBIN 2>/dev/null); l=$(EL=$el bash $HERE/case.sh $c L $B/$LAWBIN 2>/dev/null)
  o=$(EL=$el bash $HERE/case.sh $c O $B/$LAWBIN R11U224_OFF=1 2>/dev/null)
  pm=$(echo "$p" | grep -o 'md5=[0-9a-f]*'); lm=$(echo "$l" | grep -o 'md5=[0-9a-f]*'); om=$(echo "$o" | grep -o 'md5=[0-9a-f]*')
  printf "%s\tP:%s\tL:%s\t%s\t%s\tP%s\tL%s\n" "$(echo "$p" | awk '{print $1}')" "$(echo "$p" | V)" "$(echo "$l" | V)" "$([ -n "$pm" ] && [ "$om" = "$pm" ] && echo OFF=pristine || echo OFF=DIFF)" "$([ "$lm" = "$pm" ] && echo bytes=same || echo bytes=moved)" "$(echo "$p" | R)" "$(echo "$l" | R)"; }
export -f one V R; export HERE
{ if [ -n "$LIST" ]; then cat "$LIST"; else find ${1:?root} \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u; fi; } | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P${GRIDJ:-3} -L1 bash -c 'one $0 $1' | sort
