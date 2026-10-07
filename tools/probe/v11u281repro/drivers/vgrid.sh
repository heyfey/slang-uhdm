#!/bin/bash
# v11u281 vgrid.sh <out> <configs> <case dir>... : each case in both views under each configuration
# (P = pristine, L = law, OFF = law + R11U281_OFF, FIX = the verifier's fix, FIXV = fix + R11V281_OFF,
# FIXU = fix + R11U281_OFF, R11V281_* = the fix with that refinement switched off, or a switch name = law with that switch set); one line per
# case-view-configuration with the exit code (rc=). Binaries from $B; fail-closed on $FENCED through env.sh/case.sh.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; cfgs=$2; shift 2; : > $out
one() { c=$1; el=$2; cfg=$3
  case $cfg in P) EL=$el bash $D/case.sh $c P $B/pristine ;; L) EL=$el bash $D/case.sh $c L $B/law ;;
    OFF) EL=$el bash $D/case.sh $c OFF $B/law R11U281_OFF=1 ;;
    FIX) EL=$el bash $D/case.sh $c FIX $B/fix ;; FIXV) EL=$el bash $D/case.sh $c FIXV $B/fix R11V281_OFF=1 ;; FIXU) EL=$el bash $D/case.sh $c FIXU $B/fix R11U281_OFF=1 ;;
    R11V*) EL=$el bash $D/case.sh $c $cfg $B/fix $cfg=1 ;; *) EL=$el bash $D/case.sh $c $cfg $B/law $cfg=1 ;; esac | sed "s/^/$cfg /"; }
export -f one; export D
for c in "$@"; do for el in 0 1; do for cfg in $cfgs; do echo "$c $el $cfg"; done; done; done | xargs -P 3 -n 3 bash -c 'one "$@"' _ >> $out
