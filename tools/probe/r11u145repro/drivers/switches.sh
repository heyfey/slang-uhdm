#!/bin/bash
# switches.sh: every case of this directory: pristine vs law under R11U145_OFF=1 (must be byte-identical),
# and, per single switch, the cases whose database differs from the law binary's (the switch's own grid).
D=$(cd "$(dirname "$0")/.." && pwd); P=${PRIS:-/tmp/r11u145_bin/pristine}; L=${LAW:-/tmp/r11u145_bin/law}
T=$(mktemp -d /tmp/r11u145_sw.XXXX)
cases=$(cd $D && find . -name dut.sv | sort | xargs -n1 dirname | sed 's#^\./##')
run(){ # bin env out
  (cd $D/$c && env $2 $1 dut.sv --single-unit --nobuiltin -o $3 >/dev/null 2>&1); }
same=0; n=0; diffs=0
for c in $cases; do k=$(echo $c | tr / _); n=$((n+1))
  run $P "" $T/$k.p; run $L "R11U145_OFF=1" $T/$k.off; run $L "" $T/$k.l
  if cmp -s $T/$k.p $T/$k.off; then same=$((same+1)); else echo "OFF-DIFFERS $c"; fi
  cmp -s $T/$k.p $T/$k.l || diffs=$((diffs+1))
done
echo "R11U145_OFF=1: byte-identical to pristine on $same of $n cases; the law binary differs from pristine on $diffs"
for sw in R11U145_DEFFILLIMP_OFF R11U145_UNSPARAMTS_OFF R11U145_PSBAREREF_OFF R11U145_UNARYOWN_OFF R11U145_LPBOUNDOWN_OFF R11U145_BASESELOP_OFF R11U145_IMPARITH_OFF; do
  mv=""; for c in $cases; do k=$(echo $c | tr / _); run $L "$sw=1" $T/$k.s; cmp -s $T/$k.s $T/$k.l || mv="$mv $c"; done
  echo "$sw moves:$mv"
done
rm -rf $T
