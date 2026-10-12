#!/bin/bash
# v11u301 swgrid.sh <out> <case dir>...: the law binary with each of the twelve R11U301_<LAW>_OFF switches, both views
# (the per-law attribution of every mover). Source env.sh first.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
[ -x "$B/law" ] || exit 2
out=$1; shift; : > $out
for c in "$@"; do for el in 0 1; do
  for sw in CAINSIDE SELPARAMREUSE CONSTVARINIT TERNREAL TERNTPQUERY TERNPARAMARM SETCASTW DLYLITFRESH IFDLYCONST FILLAGGELAB PUREPROTO PUREAGG; do
    EL=$el bash $D/case.sh $c S_$sw $B/law R11U301_${sw}_OFF=1 | sed "s/^/$sw /" >> $out; done
done; done
