#!/usr/bin/env bash
# r10earl77 -- build ONE arm with Surelog (golden) and with BOTH frozen
# binaries in BOTH views, run the OFFICIAL uhdm-cmp on each of the four
# ours-databases, and census all five with cen77 (ports) and sig77 (signals).
#   usage: CEN77=<bin> SIG77=<bin> PRIS=<p> PATCHED=<q> arm77.sh <file.sv> <outdir>
# PATCHED may equal PRIS while no patch exists yet.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDMCMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CEN=${CEN77:?}; SIG=${SIG77:?}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "CMP $t MISSING"; continue; }
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CMP" "$D/g.uhdm" "$D/$t.uhdm" \
      > "$D/$t.cmp.out" 2> "$D/$t.cmp.err"
  echo "CMP $t rc=$? lines=$(wc -l < "$D/$t.cmp.err") heads=$( { grep -c '^LHS:' "$D/$t.cmp.err"; true; } )"
done
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$D/$t.uhdm" 2>/dev/null \
    | sed -E 's#\|LOC=[^|]*\|#|#' | sort > "$D/$t.cen"
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$SIG" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.sig"
done
echo "WD=$D"
