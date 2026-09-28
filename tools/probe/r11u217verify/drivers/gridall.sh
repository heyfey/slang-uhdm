#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) gridall.sh <out prefix> [--el] : grid.py on every case of cases/ (three cases at a time), one output per
# case under <out prefix>.d/, concatenated in case order into <out prefix>.txt.  Fail-closed on $FENCED (env.sh).
source "$(dirname "$0")/env.sh" || exit 2
O=$1; shift; mkdir -p $O.d
find $R217_DIR/cases -name 'dut.sv' -o -name 'dut.v' -o -name args | xargs -n1 dirname | sort -u > $O.list   # r11u213: args cases too
cat $O.list | xargs -P3 -I{} bash -c 'n=$(echo {} | sed "s#.*/cases/##; s#/#_#g"); python3 '"$R217_DIR"'/drivers/grid.py '"$*"' {} > '"$O"'.d/$n.txt 2>&1'
for c in $(cat $O.list); do n=$(echo $c | sed "s#.*/cases/##; s#/#_#g"); cat $O.d/$n.txt; done > $O.txt
echo "cases=$(wc -l < $O.list) results=$(grep -c '^RESULT' $O.txt)"
