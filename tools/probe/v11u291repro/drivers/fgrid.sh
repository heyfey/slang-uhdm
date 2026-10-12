#!/bin/bash
# v11u291 fgrid.sh <case dir>: one case in both views on pristine (P), the delivered law (L), the fix (F), the fix
# with R11V291_OFF (FVOFF, must equal L), with R11U291_OFF (FUOFF, must equal P) and with each refinement switch
# off (FV_<X>); every line carries the exit code. Binaries from $B (pristine, law, fix); the drivers of
# r11u291repro (env.sh fail-closed on $FENCED, case.sh) do the work. Export B and S.
D=$(cd "$(dirname "$0")/../../r11u291repro/drivers" && pwd); . "$D/env.sh" || exit 2
c=$1
for el in 0 1; do
  EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /'
  EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /'
  EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /'
  EL=$el bash $D/case.sh $c FVOFF $B/fix R11V291_OFF=1 | sed 's/^/FVOFF /'
  EL=$el bash $D/case.sh $c FUOFF $B/fix R11U291_OFF=1 | sed 's/^/FUOFF /'
  for sw in GENSHADOW BODYTD CLASSTP; do EL=$el bash $D/case.sh $c FV_$sw $B/fix R11V291_${sw}_OFF=1 | sed "s/^/FV_$sw /"; done
done
