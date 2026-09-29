#!/bin/bash
# grid.sh <law-binary> <cases-subdir...> : every case in both views: pristine (P), law (L), law under R11U228_OFF (O).
# Prints one line per case-view: case view P-verdict L-verdict O-same-as-P(md5).
H="$(cd "$(dirname "$0")" && pwd)"; . "$H/env.sh" || exit 2
LAW=$1; shift
[ -x "$LAW" ] && [ -x "$B/pristine" ] || { echo "grid: binaries missing" >&2; exit 2; }
for sub in "$@"; do
  for c in $(ls -d $H/../cases/$sub/*/ | sort); do
    for el in 0 1; do
      p=$(EL=$el bash $H/case.sh $c P $B/pristine)
      l=$(EL=$el bash $H/case.sh $c L $LAW)
      o=$(EL=$el bash $H/case.sh $c O $LAW R11U228_OFF=1)
      pm=${p##*md5=}; om=${o##*md5=}
      ps=$(echo "$p" | grep -o 'strict=[^ ]*'); ls=$(echo "$l" | grep -o 'strict=[^ ]*')
      pc=$(echo "$p" | grep -o 'cmp=[^ ]*'); lc=$(echo "$l" | grep -o 'cmp=[^ ]*')
      echo "$sub/$(basename $c) el=$el P:$pc,$ps L:$lc,$ls OFF=$([ "$pm" = "$om" ] && echo pristine || echo MOVED) Lmd5=${l##*md5=} Pmd5=$pm"
    done
  done
done
