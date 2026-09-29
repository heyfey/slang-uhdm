#!/bin/bash
# switches.sh <law-binary> <cases-subdir...> : per case-view, the md5 of the law binary under each single switch;
# prints the switches whose bytes differ from the law's (SAME = no effect).
H="$(cd "$(dirname "$0")" && pwd)"; . "$H/env.sh" || exit 2
LAW=$1; shift
SW="R11U225_IFARRELEMCA_OFF R11U225_INITHIERSPAN_OFF R11U225_INITHIERCANAME_OFF R11U225_INITHIERFILL_OFF"
for sub in "$@"; do
  for c in $(ls -d $H/../cases/$sub/*/ | sort); do
    for el in 0 1; do
      l=$(EL=$el bash $H/case.sh $c L $LAW); lm=${l##*md5=}
      out=""
      for s in $SW; do
        o=$(EL=$el bash $H/case.sh $c S $LAW $s=1); om=${o##*md5=}
        [ "$om" != "$lm" ] && out="$out ${s#R11U225_}:$(echo "$o" | grep -o 'strict=[^ ]*' | sed 's/strict=//')"
      done
      echo "$sub/$(basename $c) el=$el moved_by:${out:- none}"
    done
  done
done
