#!/bin/bash
# gridcmp.sh <tagA> <binA> <tagB> <binB> [casedir-root...]: every case under the roots (default: this pass's cases/),
# both views, judged with MAX=100000; prints one line per case-mode: verdict A, verdict B, record movement A->B
# (drivers/recmv.py: LEAVE / ENTER / CHANGED keyed on the walk index and the golden record) and the dump-md5 move.
D=$(cd "$(dirname "$0")" && pwd)
ta=$1; ba=$2; tb=$3; bb=$4; shift 4
roots=("$@"); [ ${#roots[@]} -eq 0 ] && roots=("$D/../cases")
export MAX=100000
for root in "${roots[@]}"; do
  for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
    for e in "" 1; do
      a=$(ELAB=$e $D/grid.sh $c $ba $ta R11U184_TRACE=1); b=$(ELAB=$e $D/grid.sh $c $bb $tb R11U184_TRACE=1)
      rel=$(echo "$a" | awk '{print $1}')
      w=/tmp/r11u184_g/$rel
      mv=$(python3 $D/recmv.py $w/$ta.strict $w/$tb.strict 2>/dev/null | head -1)
      fires=$(grep -c 'R11U184 law' $w/$tb.log)
      echo "$rel | $(echo "$a" | grep -o 'strict=[^ ]*') -> $(echo "$b" | grep -o 'strict=[^ ]*') | $mv | fires=$fires | $( [ "$(echo "$a" | grep -o 'md5=.*')" = "$(echo "$b" | grep -o 'md5=.*')" ] && echo bytes-same || echo bytes-moved)"
    done
  done
done
