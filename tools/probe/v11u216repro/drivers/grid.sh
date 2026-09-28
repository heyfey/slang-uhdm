#!/bin/bash
# v11u216 (copied from r11u216repro/drivers/grid.sh): judge every case dir under cases/ (dut.sv) in both views (EL=0 the parse form, EL=1 --elabuhdm / -elabuhdm)
# with the frozen binaries named in $GRIDBINS (files in $B), one line per case-view: <case> <verdict per binary>, and
# with OFFCHECK=1 the last binary under R11U216_OFF=1 compared byte for byte with the first (OFF=pristine|OFF=DIFF);
# with VOFFBIN=<bin> the last binary under R11V216_OFF=1 compared byte for byte with <bin>'s output (VOFF=<bin>|VOFF=DIFF).
# Uses case.sh (fence fail-closed).  usage: grid.sh [subdir] > grid.tsv
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
V() { awk '{ for (i=1;i<=NF;i++) if ($i ~ /^strict=/) { s=substr($i,8); if (s ~ /^STRICT_EQUAL/) print "EQUAL"; else print s } ; if ($3=="SURELOG_FAIL"||$3=="SLANG_FAIL") print $3 }' | head -1; }
one() { c=$1; el=$2; line=""; first=""; last=""
  for b in ${GRIDBINS:-slang-uhdm law.bin}; do
    r=$(EL=$el bash $HERE/case.sh $c $b $B/$b 2>/dev/null); [ -z "$line" ] && line=$(echo "$r" | awk '{print $1}')
    md=$(echo "$r" | grep -o 'md5=[0-9a-f]*'); [ -z "$first" ] && first=$md; last=$b
    line="$line	$b:$(echo "$r" | V)"; done
  if [ -n "${VOFFBIN:-}" ]; then
    lm=$(echo "$line" | head -1 >/dev/null; EL=$el bash $HERE/case.sh $c $VOFFBIN $B/$VOFFBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*')
    r=$(EL=$el bash $HERE/case.sh $c voff_$last $B/$last R11V216_OFF=1 2>/dev/null); md=$(echo "$r" | grep -o 'md5=[0-9a-f]*')
    [ "$md" = "$lm" ] && line="$line	VOFF=$VOFFBIN" || line="$line	VOFF=DIFF"
  fi
  if [ "${OFFCHECK:-0}" = 1 ]; then
    r=$(EL=$el bash $HERE/case.sh $c off_$last $B/$last R11U216_OFF=1 2>/dev/null); md=$(echo "$r" | grep -o 'md5=[0-9a-f]*')
    [ "$md" = "$first" ] && line="$line	OFF=pristine" || line="$line	OFF=DIFF"
  fi
  echo "$line"; }
export -f one V; export HERE GRIDBINS OFFCHECK VOFFBIN
find ${CASES:-$HERE/../cases}/${1:-} -name dut.sv -printf '%h\n' | sort | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort
