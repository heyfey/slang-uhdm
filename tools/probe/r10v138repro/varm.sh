#!/usr/bin/env bash
# r10v138 verifier — one arm: Surelog golden (both views) + both frozen
# binaries (both views); census with cen138.py over uhdm-dump; official cmp.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/wt_v138/tools/probe/r10uvm138repro/cen138.py
PRIS=/tmp/v138_bin/pris.bin; PAT=/tmp/v138_bin/pat.bin
F=$(readlink -f "$1"); D=$(readlink -f "$2"); mkdir -p "$D"; B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PAT"  "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PAT"  "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g ge o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "$t MISSING"; continue; }
  "$DUMP" "$D/$t.uhdm" > "$D/$t.dump" 2>/dev/null
  python3 "$CEN" "$D/$t.dump" | sort > "$D/$t.cen"
  echo "$t cells=$(wc -l < "$D/$t.cen")"
done
for p in "g o" "g q" "ge oe" "ge qe"; do
  set -- $p
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || continue
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$2.cmp" 2>&1
  echo "cmp $1-vs-$2 rc=$? lines=$(wc -l < "$D/$2.cmp") heads=$(grep -c '^LHS:' "$D/$2.cmp"; true)"
done
echo "WD=$D"
