#!/bin/bash
# r11u229: detdump.sh <det dir>...: for every database a det.sh run wrote (<dir>/<row>_<mode>_<i>.uhdm), the md5 of the
# database and of its uhdm-dump (the `Restored design` line dropped and the database's own path normalised; ids and
# object order kept: an UNSORTED dump) and of the sorted dump.  One dump per distinct database md5 (cached beside it).
# The six rows det.sh runs are not fenced; fail-closed on $FENCED anyway.
source "$(dirname "$0")/env.sh" || exit 2
for d in "$@"; do
  for u in $(ls $d/*.uhdm | sort); do
    b=$(basename $u .uhdm); echo "$b" | grep -Eqw "$(echo $FENCED | tr ' ' '|')" && { echo "$b fenced refused"; continue; }
    h=$(md5sum < $u | cut -c1-12); c=$d/.dump_$h
    if [ ! -s $c.u ]; then
      "$UHDM_DUMP" $u 2>/dev/null | grep -v 'Restored design' | sed "s#$u#DB#g" > $c.txt
      md5sum < $c.txt | cut -c1-12 > $c.u; sort $c.txt | md5sum | cut -c1-12 > $c.s; rm -f $c.txt
    fi
    echo "$(basename $d) $b db=$h dump=$(cat $c.u) sorted=$(cat $c.s)"
  done
done
