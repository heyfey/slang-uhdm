#!/bin/bash
# gridall.sh <binary> <tag> [outroot]: every case under cases/ through grid1.sh; one line per case.
D=$(cd "$(dirname "$0")" && pwd); C=$D/../cases
for c in $(find $C -name dut.sv | sort); do
  d=$(dirname $c); echo -n "$(basename $(dirname $d))/"; bash $D/grid1.sh $d $1 $2 ${3:-/tmp/r11u151_g}
done
