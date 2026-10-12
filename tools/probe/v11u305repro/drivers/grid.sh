#!/bin/bash
# v11u305 grid.sh <out> <config-list> <case dir>... : every case in both views on each configuration; one line per
# case-view-configuration with rc=. Configurations: P (pristine), L (law), F (fix, when $B/fix exists), OFF (law +
# R11U305_OFF), FOFF (fix + R11V305_OFF), FUOFF (fix + R11U305_OFF), X_<SW> (law with R11U305_<SW>_OFF), FX_<SW> (fix with R11V305_<SW>_OFF).
H=$(cd "$(dirname "$0")" && pwd); . $H/env.sh || exit 2
out=$1; cfgs=$2; shift 2; : > $out
jobs=()
for c in "$@"; do for el in 0 1; do for k in $cfgs; do jobs+=("$el $k $c"); done; done; done
printf '%s\n' "${jobs[@]}" | xargs -P 3 -L 1 bash -c '
el=$0; k=$1; c=$2; H='"$H"'
case $k in
 P) b=$B/pristine; e=();; L) b=$B/law; e=();; F) b=$B/fix; e=();;
 OFF) b=$B/law; e=(R11U305_OFF=1);; FOFF) b=$B/fix; e=(R11V305_OFF=1);; FUOFF) b=$B/fix; e=(R11U305_OFF=1);;
 X_*) b=$B/law; e=(R11U305_${k#X_}_OFF=1);; FX_*) b=$B/fix; e=(R11V305_${k#FX_}_OFF=1);;
esac
echo "$k $(EL=$el bash $H/case.sh $c $k $b "${e[@]}" X305=1)"' >> $out
sort -o $out $out
