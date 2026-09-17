#!/usr/bin/env bash
# r11u57 DIRECTION SCORER — for every grid arm, the ORDER-BLIND whole-dump
# residue against GOLDEN under the pristine binary and under the patched one.
#
# The cell scorer says WHICH object sits at a site; this says whether the arm
# as a whole moved TOWARD golden or AWAY from it, which is the gate's question.
# Residue = golden-only + ours-only lines of a sorted, path-normalised
# uhdm-dump diff.  DOWN is toward golden, UP is away, and an arm whose residue
# does not move is an arm the law did not touch (the negative control
# `w3_typedef_view` is one by construction).
#
#   usage: toward53.sh [<arm> ...]      (default: every arm)
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:-$(ls -d $R/grid/*/ | xargs -n1 basename | sort -V)}
printf "%-18s %8s %8s %8s %8s  %s\n" ARM A_g A_o B_g B_o DIRECTION
for a in $ARMS; do
  d=$R/grid/$a
  g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { printf "%-18s %8s %8s %8s %8s  %s\n" "$a" - - - - NO-GOLDEN; continue; }
  $DUMP "$g" 2>/dev/null | sed -e "s#$d/##g" | sort > /tmp/.tw57.g.$$
  out=""
  for t in ${TAGS:-base law}; do
    o=$d/ours.$t.uhdm
    [ -f "$o" ] || { out="$out - -"; continue; }
    $DUMP "$o" 2>/dev/null | sed -e "s#$d/##g" | sort > /tmp/.tw57.o.$$
    diff /tmp/.tw57.g.$$ /tmp/.tw57.o.$$ > /tmp/.tw57.d.$$; true
    out="$out $(grep -c '^<' /tmp/.tw57.d.$$; true) $(grep -c '^>' /tmp/.tw57.d.$$; true)"
  done
  set -- $out
  tb=$(( ${1:-0} + ${2:-0} )); tp=$(( ${3:-0} + ${4:-0} ))
  dir=UNCHANGED; [ $tp -lt $tb ] && dir="TOWARD-GOLDEN (-$((tb-tp)))"; [ $tp -gt $tb ] && dir="AWAY-GOLDEN (+$((tp-tb)))"
  printf "%-18s %8s %8s %8s %8s  %s\n" "$a" "$1" "$2" "$3" "$4" "$dir"
  rm -f /tmp/.tw57.o.$$ /tmp/.tw57.d.$$
done
rm -f /tmp/.tw57.g.$$
