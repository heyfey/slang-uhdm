#!/usr/bin/env bash
# attr108.sh <ship_wd> <pris_wd> — ORDER-BLIND whole-dump attribution of every
# moved database (Scoreboard/default is a ~50/50 coin, so the dumps are SORTED
# and the workdir prefix normalised out before the diff).
set -u
S=${1:?}; P=${2:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
tot=0
for f in $(cd "$S" && find . -name slang.uhdm | sort); do
  a=$(md5sum "$S/$f" | cut -c1-12); b=$(md5sum "$P/$f" | cut -c1-12)
  [ "$a" = "$b" ] && continue
  $DUMP "$S/$f" 2>/dev/null | sed "s#$S##; s#$P##" | sort > /tmp/r10uvm110_at_s.txt
  $DUMP "$P/$f" 2>/dev/null | sed "s#$S##; s#$P##" | sort > /tmp/r10uvm110_at_p.txt
  add=$(diff /tmp/r10uvm110_at_p.txt /tmp/r10uvm110_at_s.txt | grep -c '^>'; true)
  del=$(diff /tmp/r10uvm110_at_p.txt /tmp/r10uvm110_at_s.txt | grep -c '^<'; true)
  echo "== $f  added=$add removed=$del"
  diff /tmp/r10uvm110_at_p.txt /tmp/r10uvm110_at_s.txt | grep -E '^[<>]' | sed 's/^\(.\) */\1 /' | sort | uniq -c | sort -rn
  tot=$((tot+1))
done
echo "ATTRIBUTED $tot databases"
