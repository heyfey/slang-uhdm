#!/bin/bash
# grid.sh <casedir>...: pristine / law / verified readings + switch byte checks
# columns: case | law | pristine | law | verified | R11U433_OFF==pristine | law-switch==pristine | R11V433_OFF==law | fix-switch==law
P=/tmp/v11u433_bin/pristine; L=/tmp/v11u433_bin/law; V=/tmp/v11u433_bin/ver3; R=/tmp/v11u433_scr/drv
O=/tmp/v11u433_scr/out
for c in "$@"; do
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); key=$(echo $c | sed "s|.*/cases/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/switches.txt)
  p=$(bash $R/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/run1.sh $c $L l | cut -d' ' -f2-)
  v=$(bash $R/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/run1.sh $c $L o R11U433_OFF=1 >/dev/null
  bash $R/run1.sh $c $V vo R11V433_OFF=1 >/dev/null
  case $sw in R11U433*) bash $R/run1.sh $c $L s $sw=1 >/dev/null; ref=p;; R11V433*) bash $R/run1.sh $c $V s $sw=1 >/dev/null; ref=l;; *) bash $R/run1.sh $c $L s R11U433_NONE=1 >/dev/null; ref=l;; esac
  eq(){ cmp -s $O/$key/$1/ours.uhdm $O/$key/$2/ours.uhdm && [ "$(cat $O/$key/$1/rc)" = "$(cat $O/$key/$2/rc)" ] && echo same || echo DIFF; }
  echo "$g/$n | $law | pristine $p | law $l | ver $v | U433OFF $(eq o p) | $sw $(eq s $ref) | V433OFF $(eq vo l) | ver-vs-law $(eq v l)"
done
