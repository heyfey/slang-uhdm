#!/usr/bin/env bash
# r11u82 ARM DISTANCE — order-blind line distance golden-vs-ours per arm and
# per tag.  `gold_only` = golden lines with no counterpart in ours,
# `ours_only` = the reverse.  A tag whose ours_only RISES has minted something
# golden lacks; a tag whose gold_only RISES has dropped something golden has.
set -u
GRID=${GRID:?set GRID}
printf '%-14s %-24s %-24s\n' arm "$1" "$2"
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a
  out="$a"
  for t in "$1" "$2"; do
    g=$d/gold.$t.dump; o=$d/ours.$t.dump
    if [ -f "$g" ] && [ -f "$o" ]; then
      sed -e '1d' "$g" | sort > /tmp/r11u82_sc_g.$$
      sed -e '1d' "$o" | sort > /tmp/r11u82_sc_o.$$
      go=$(comm -23 /tmp/r11u82_sc_g.$$ /tmp/r11u82_sc_o.$$ | wc -l)
      oo=$(comm -13 /tmp/r11u82_sc_g.$$ /tmp/r11u82_sc_o.$$ | wc -l)
      out="$out $(printf '%8s' "$go/$oo")"
    else
      out="$out       NA"
    fi
  done
  printf '%-14s %s\n' $a "${out#$a }"
done
rm -f /tmp/r11u82_sc_g.$$ /tmp/r11u82_sc_o.$$
