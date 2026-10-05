#!/bin/bash
# (v11u253) vgrid.sh <cases root> <outfile> [jobs]: every case dir (cases/<F>/<case>) under the root in both views on
# pristine, law, law + R11U253_OFF and law + each switch, through case.sh (one line per run, exit code included);
# cases run in parallel, the lines sorted at the end. Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); root=$(realpath $1); out=$2; j=${3:-3}
one() {
  c=$1; H=$2
  for el in 0 1; do
    EL=$el $H/case.sh $c pristine $B/pristine
    EL=$el $H/case.sh $c law ${LAWBIN:-$B/law}
    EL=$el $H/case.sh $c lawOFF ${LAWBIN:-$B/law} R11U253_OFF=1
    for s in R11U253_MINTHOME_OFF R11U253_TFITEMOWN_OFF R11U253_HOMEARRELAB_OFF R11U253_TFFIXARRTS_OFF R11U253_FORMALTS_OFF; do
      EL=$el $H/case.sh $c "law-$s" ${LAWBIN:-$B/law} $s=1
    done
  done > $S/vgrid_$(echo $c | md5sum | cut -c1-10).part
}
export -f one
ls -d $root/*/* | grep -vwE "$FENCE_RE" | xargs -P $j -I{} bash -c 'one {} '"$H"
cat $(for c in $(ls -d $root/*/* | grep -vwE "$FENCE_RE"); do echo $S/vgrid_$(echo $c | md5sum | cut -c1-10).part; done) | sort -k1,1 -s > $out
