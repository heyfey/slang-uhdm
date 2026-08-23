#!/usr/bin/env bash
# r10v77 VERIFIER arm runner: golden (Surelog) + BOTH frozen binaries in BOTH
# views; official uhdm-cmp on each of the four ours-databases; port + signal
# census of all five.  Every cell records rc.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
P=/tmp/v77_bin/pristine; Q=/tmp/v77_bin/patched
CEN=/tmp/v77_arms/v77port; SIG=/tmp/v77_arms/v77sig
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && timeout 300 "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && timeout 300 "$P" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && timeout 300 "$P" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && timeout 300 "$Q" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && timeout 300 "$Q" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "CMP $t MISSING-DB"; continue; }
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CMP" "$D/g.uhdm" "$D/$t.uhdm" > "$D/$t.cmp.out" 2> "$D/$t.cmp.err"
  echo "CMP $t rc=$? lines=$(wc -l < "$D/$t.cmp.err") heads=$( { grep -c '^LHS:' "$D/$t.cmp.err"; true; } )"
done
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.port"
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$SIG" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.sig"
done
echo "WD=$D"
