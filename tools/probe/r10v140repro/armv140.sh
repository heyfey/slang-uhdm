#!/usr/bin/env bash
# r10v140 (VERIFIER) — build ONE arm with Surelog (golden) and with the two
# frozen binaries, in BOTH views; dump all six; official uhdm-cmp on all four
# golden-vs-ours pairs.  LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
# Every child </dev/null; every rc printed (rc=139 is a SEGFAULT).
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLE   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g ge o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$DUMP" "$D/$t.uhdm" 2>/dev/null | sed "s|$D/||g; s|$D||g" > "$D/$t.dump"
done
for pair in "g o" "g q" "ge oe" "ge qe"; do
  set -- $pair; G=$1; T=$2
  [ -f "$D/$T.uhdm" ] && [ -f "$D/$G.uhdm" ] || continue
  "$CMP" "$D/$G.uhdm" "$D/$T.uhdm" > "$D/$T.cmp" 2>&1
  echo "CMP $G-vs-$T rc=$? lines=$(wc -l < "$D/$T.cmp") heads=$(grep -c '^LHS:' "$D/$T.cmp"; true) head=$(grep -m1 '^LHS:' "$D/$T.cmp" | cut -c1-90)"
done
# byte movement of OUR two databases
for pair in "o q" "oe qe"; do
  set -- $pair
  if [ -f "$D/$1.uhdm" ] || [ -f "$D/$2.uhdm" ]; then
    if cmp -s "$D/$1.uhdm" "$D/$2.uhdm"; then echo "BYTES $1-vs-$2 SAME"; else echo "BYTES $1-vs-$2 MOVED"; fi
  fi
done
echo "WD=$D"
