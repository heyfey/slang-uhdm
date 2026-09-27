#!/bin/bash
# r11u186: the downstream verdict of every case dir (dut.sv) under the given roots, pristine vs final (dscase.sh);
# prints `<case> <pristine verdict> <final verdict>`.  usage: dsgrid.sh <tag> <root>...
T=$1; shift; H=$(cd "$(dirname "$0")" && pwd)
for r in "$@"; do find $(cd $r && pwd) -name dut.sv -printf '%h\n'; done | sort -u > /tmp/r11u186_dsg_$T.list
for b in pris.bin final.bin; do
  while read -r c <&3; do
    v=$(bash $H/dscase.sh /tmp/r11u186_bin/$b $c 2>/dev/null | python3 -c "import sys,ast
for l in sys.stdin:
    l=l.strip()
    if l.startswith('{'): print(ast.literal_eval(l)['verdict'])" | tail -1)
    echo "$(echo $c | sed 's#.*/tools/probe/##') ${v:-NONE}"
  done 3< /tmp/r11u186_dsg_$T.list > /tmp/r11u186_dsg_$T.$b
done
join <(sort /tmp/r11u186_dsg_$T.pris.bin) <(sort /tmp/r11u186_dsg_$T.final.bin)
