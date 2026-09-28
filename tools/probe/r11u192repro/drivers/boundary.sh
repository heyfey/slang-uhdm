#!/bin/bash
# boundary.sh <pristine bin> <law bin> <out file> <dir>...: every case dir (holding dut.sv) under the given directories,
# default view, both binaries; prints `SAME|MOVED <rel>` per case and, for every mover, the strict verdicts and the
# order-blind distance (grid.sh + obdist.py).  Fence-refusing (a path matching a fenced name is skipped and counted).
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 9
P=$1; L=$2; O=$3; shift 3
T=/tmp/r11u192_bnd; mkdir -p $T; : > $O
n=0; m=0; f=0
for root in "$@"; do
  while read -r c <&3; do
    if echo "$c" | grep -qP "$FENCED_RE"; then f=$((f+1)); continue; fi
    n=$((n+1)); rm -f $T/p.uhdm $T/l.uhdm
    (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm > /dev/null 2>&1 </dev/null)
    (cd $c && $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm > /dev/null 2>&1 </dev/null)
    rel=$(echo $c | sed -e 's#.*/tools/probe/##')
    if [ ! -e $T/p.uhdm ] && [ ! -e $T/l.uhdm ]; then echo "BOTHFAIL $rel" >> $O; continue; fi
    if cmp -s $T/p.uhdm $T/l.uhdm; then echo "SAME $rel" >> $O; continue; fi
    m=$((m+1))
    a=$($D/grid.sh $c $P P </dev/null); b=$($D/grid.sh $c $L L </dev/null)
    w=/tmp/r11u192_g/tp/$rel
    ob=$( [ -s $w/P.dump ] && [ -s $w/L.dump ] && python3 $D/obdist.py $w/gold.dump $w/P.dump $w/L.dump)
    echo "MOVED $rel | $(echo "$a" | grep -oE 'strict=[^ ]*|SLANG_FAIL|SURELOG_FAIL') cmp=$(echo "$a" | grep -o 'cmplines=[0-9]*' | cut -d= -f2) -> $(echo "$b" | grep -oE 'strict=[^ ]*|SLANG_FAIL|SURELOG_FAIL') cmp=$(echo "$b" | grep -o 'cmplines=[0-9]*' | cut -d= -f2) | ob $ob | $(echo "$b" | grep -o 'fires=.*')" >> $O
  done 3< <(find $root -name dut.sv -printf '%h\n' | sort)
done
echo "BOUNDARY processed=$n moved=$m fenced_skipped=$f" >> $O
