#!/usr/bin/env bash
# r11u25 — cell-level direction for a boundary mover: how many elaborated
# cont_assign cells differ from the REAL golden, on each binary.
set -u
OUT=${OUT:-/tmp/r11u25_bndattr}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
C=/tmp/r11u25_scr/carhs25.py
for f in "$@"; do
  key=$(echo "$f" | sed 's#^/##; s#/#_#g'); d=$OUT/$key
  g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "$(basename $(dirname "$f"))/$(basename "$f")  NO-GOLDEN"; continue; }
  $DUMP "$g" 2>/dev/null > $d/.g.dmp 2>/dev/null; python3 $C $d/.g.dmp 2>/dev/null | sort > $d/.g.cells
  for tag in pris law; do
    if [ -f $d/$tag.uhdm ]; then
      $DUMP $d/$tag.uhdm 2>/dev/null > $d/.$tag.dmp 2>/dev/null; python3 $C $d/.$tag.dmp 2>/dev/null | sort > $d/.$tag.cells
    else : > $d/.$tag.cells; fi
  done
  n=$(wc -l < $d/.g.cells)
  dp=$(diff $d/.g.cells $d/.pris.cells | grep -c '^[<>]'; true)
  dl=$(diff $d/.g.cells $d/.law.cells | grep -c '^[<>]'; true)
  v=SAME; [ "$dl" -lt "$dp" ] && v=TO-GOLDEN; [ "$dl" -gt "$dp" ] && v=AWAY-GOLDEN
  printf "%-52s cells=%-4s pris_diff=%-4s law_diff=%-4s %s\n" \
    "$(basename $(dirname "$f"))/$(basename "$f")" "$n" "$dp" "$dl" "$v"
done
