#!/bin/bash
# v11u262 tri.sh <case dir>...: every case in both views on $B/pristine (P), $B/law (L), $B/fix (F) and $B/fix with
# R11V262_OFF=1 (FV, must equal L); case.sh lines (exit codes included). Paths from this checkout; $FENCED fail-closed
# through env.sh and case.sh. The caller exports B, S and the tool pins.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
for c in "$@"; do c=$(realpath $c); for el in 0 1; do
 for t in P L F FV; do case $t in P) b=pristine; e=X=1;; L) b=law; e=X=1;; F) b=fix; e=X=1;; FV) b=fix; e=R11V262_OFF=1;; esac
  EL=$el bash $D/case.sh $c $t $B/$b $e; done; done; done
