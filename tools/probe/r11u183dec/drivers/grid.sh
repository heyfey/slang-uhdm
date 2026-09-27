#!/bin/bash
# r11u183: judge every case of cases/ with the four frozen binaries (pristine, lawJ = both patches, lawHA =
# law_exprstmt.patch alone, lawJB = law_typeemit.patch alone; GRIDBINS overrides) exactly as check_probe.py does (case.sh);
# one line per case: <case> <pristine verdict> <law> <lawA> <lawB>.   usage: grid.sh > grid.tsv
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh"
one() { c=$1; r=$(basename $(dirname $c))/$(basename $c); line="$r"
  for b in ${GRIDBINS:-slang-uhdm slang-uhdm.lawJ slang-uhdm.lawHA slang-uhdm.lawJB}; do
    v=$(SLANG_UHDM=/tmp/r11u183_bin/$b bash $HERE/case.sh $c /tmp/r11u183_grid/$b/$r 2>/dev/null | awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4"("n")" }' n=$(grep -o 'objects_differing=[0-9]*' /tmp/r11u183_grid/$b/$r/strict.txt 2>/dev/null | cut -d= -f2))
    [ -z "$v" ] && v=$(SLANG_UHDM=/tmp/r11u183_bin/$b bash $HERE/case.sh $c /tmp/r11u183_grid/$b/$r 2>/dev/null | awk '{print $1}')
    n=$(grep -o 'objects_differing=[0-9]*' /tmp/r11u183_grid/$b/$r/strict.txt 2>/dev/null | cut -d= -f2)
    case "$v" in STRICT_NOTEQUAL*) v="STRICT_NOTEQUAL:$(grep -m1 '^STRICT_NOTEQUAL' /tmp/r11u183_grid/$b/$r/strict.txt | cut -d' ' -f2)($n)";; esac
    line="$line	$v"; done; echo "$line"; }
export -f one; export HERE GRIDBINS
find $HERE/../cases -name dut.sv -printf '%h\n' | sort | xargs -P2 -I{} bash -c 'one {}' | sort
