#!/usr/bin/env bash
# r10uvm137 — ORDER-BLIND mover attribution.  MEASUREMENT ONLY.
# Both dumps are id- and workdir-normalised and LC_ALL=C sorted before the
# diff, because Scoreboard/default (and SeqDriver) are ~50/50 COINS per
# invocation and may only be attributed order-blind (RESUME.md §9).
#   usage: PRIS=<prisWD> PAT=<patWD> movers137.sh <mode/name-hash> ...
set -u
PRIS=${PRIS:?prisWD}; PAT=${PAT:?patWD}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
WD=${WD:-/tmp/r10uvm137_movers}
mkdir -p "$WD"
norm() { sed -e 's/id:[0-9]*//g' -e "s#$1##g" | LC_ALL=C sort; }
tot=0; unattr=0
for rel in "$@"; do
  p=$PRIS/$rel/slang.uhdm; q=$PAT/$rel/slang.uhdm
  [ -f "$p" ] && [ -f "$q" ] || { echo "SKIP-NOFILE $rel"; continue; }
  k=${rel//\//__}
  "$DUMP" "$p" 2>/dev/null </dev/null | norm "$PRIS" > "$WD/$k.pris"
  "$DUMP" "$q" 2>/dev/null </dev/null | norm "$PAT"  > "$WD/$k.pat"
  diff "$WD/$k.pris" "$WD/$k.pat" | grep '^[<>]' > "$WD/$k.diff"; true
  n=$(wc -l < "$WD/$k.diff")
  # the law's own objects: the loop variable (class_var -> int_var), its
  # typespec (class_typespec 'uvm_phase' -> int_typespec) and the three lines
  # the dump prints INSIDE that class_typespec (its class_defn back-pointer,
  # `|vpiClassDefn:` and `|vpiName:<class>`), which leave with it.
  u=$(grep -vcE 'class_var|class_typespec|int_var|int_typespec|class_defn|vpiClassDefn|vpiName:uvm_phase' "$WD/$k.diff"); true
  echo "$rel  lines=$n  unattributed=$u"
  grep -vE 'class_var|class_typespec|int_var|int_typespec|class_defn|vpiClassDefn|vpiName:uvm_phase' "$WD/$k.diff" | sed 's/^/    /' | head -5
  tot=$((tot+n)); unattr=$((unattr+u))
done
echo "TOTAL differing lines=$tot UNATTRIBUTED=$unattr"
