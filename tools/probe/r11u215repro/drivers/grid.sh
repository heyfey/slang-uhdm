#!/bin/bash
# r11u215: judge every case of cases/ with the frozen binaries in $GRIDBINS (default: pristine and law), one line per
# case: <case> <verdict per binary>; with OFFCHECK=1 also the law binary under R11U215_OFF=1 and whether its database
# is byte-identical to the pristine one (the one-switch-restores-pristine check).  Uses case.sh (fence fail-closed).
# usage: grid.sh [case glob relative to cases/] > grid.tsv
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; r=${c#$HERE/../cases/}; line="$r"
  for b in ${GRIDBINS:-pris.bin law.bin}; do
    v=$(SLANG_UHDM=$B/$b bash $HERE/case.sh $c /tmp/r11u215_grid${ELAB:+_elab}/$b/$r 2>/dev/null | V)
    n=$(grep -o 'objects_differing=[0-9]*' /tmp/r11u215_grid${ELAB:+_elab}/$b/$r/strict.txt 2>/dev/null | cut -d= -f2)
    [ -n "$n" ] && v="$v($n)"; line="$line	$v"; done
  if [ "${OFFCHECK:-0}" = 1 ]; then
    R11U215_OFF=1 SLANG_UHDM=$B/${LAWBIN:-law.bin} bash $HERE/case.sh $c /tmp/r11u215_grid${ELAB:+_elab}/off/$r > /dev/null 2>&1
    if cmp -s /tmp/r11u215_grid${ELAB:+_elab}/off/$r/ours.uhdm /tmp/r11u215_grid${ELAB:+_elab}/pris.bin/$r/ours.uhdm; then line="$line	OFF=pristine"; else line="$line	OFF=DIFF"; fi
  fi
  echo "$line"; }
export -f one V; export HERE GRIDBINS OFFCHECK ELAB
find $HERE/../cases/${1:-} -type f \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u | xargs -P3 -I{} bash -c 'one {}' | sort
