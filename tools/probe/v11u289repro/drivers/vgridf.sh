#!/bin/bash
# v11u289 vgridf.sh <out> <case dir>...: every case in both views on P ($B/pristine), L ($B/law), F ($FIXBIN),
# FV (fix + R11V289_OFF, must equal L), FU (fix + R11U289_OFF, must equal P) and the fix with each switch in $EXTRA
# off; one case.sh line each, exit code included. Export SURELOG UHDM_CMP UHDM_DUMP B S FIXBIN first.
D=$(cd "$(dirname "$0")" && pwd); . $D/env.sh || exit 2
F=${FIXBIN:?}; [ -x "$F" ] || exit 2
out=$1; shift; : > $out
for c in "$@"; do for el in 0 1; do
  EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
  EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
  EL=$el bash $D/case.sh $c F $F | sed 's/^/F /' >> $out
  EL=$el bash $D/case.sh $c FV $F R11V289_OFF=1 | sed 's/^/FV /' >> $out
  EL=$el bash $D/case.sh $c FU $F R11U289_OFF=1 | sed 's/^/FU /' >> $out
  for sw in $EXTRA; do EL=$el bash $D/case.sh $c $sw $F $sw=1 | sed "s/^/$sw /" >> $out; done
done; done
