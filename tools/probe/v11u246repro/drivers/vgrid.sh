#!/bin/bash
# (v11u246) vgrid.sh <cases root> <outfile> [jobs]: every case dir <root>/*/* in both views on pristine, law, fix,
# fix + R11V246_OFF (must write the law's bytes), fix + R11V246_PAEVALCTX_OFF and fix + R11U246_OFF (must write
# pristine's bytes); one case.sh line per run (exit code included).  Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); R=$(cd "$1" && pwd); out=$2; J=${3:-3}; T=$S/vgrid.$$; mkdir -p $T
for x in pristine law fix; do [ -x $B/$x ] || { echo "vgrid.sh: $B/$x not executable" >&2; exit 2; }; done
export H R T
one() {
  c=$1; f=$T/$(echo $c | tr / _); : > $f
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $R/$c pristine $B/pristine >> $f
    EL=$el $H/drivers/case.sh $R/$c law $B/law >> $f
    EL=$el $H/drivers/case.sh $R/$c fix $B/fix >> $f
    EL=$el $H/drivers/case.sh $R/$c fixVOFF $B/fix R11V246_OFF=1 >> $f
    EL=$el $H/drivers/case.sh $R/$c fixPAEVALOFF $B/fix R11V246_PAEVALCTX_OFF=1 >> $f
    EL=$el $H/drivers/case.sh $R/$c fixUOFF $B/fix R11U246_OFF=1 >> $f
  done
}
export -f one
(cd $R && ls -d */* | sort) | xargs -P $J -I{} bash -c 'one {}'
: > $out
for c in $(cd $R && ls -d */* | sort); do cat $T/$(echo $c | tr / _) >> $out; done
rm -rf $T
