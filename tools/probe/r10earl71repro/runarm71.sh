#!/usr/bin/env bash
# r10earl71 — build ONE arm with Surelog (golden), the frozen PRISTINE and the
# frozen PATCHED binary, in BOTH views, and census each with tscen71.
# MEASUREMENT ONLY.  usage: runarm71.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${TSCEN71:?set TSCEN71}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:?set PATCHED}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null )
echo "SL rc=$? $(grep -c 'FATAL. : 0' "$D/sl.log" 2>/dev/null; true)"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }
  R66_INST=1 "$CEN" "$D/$t.uhdm" > "$D/$t.raw" 2>/dev/null
  sed 's/ span=[^ ]*//g; s/ tsspan=[^ ]*//g; s/ afn=[^ ]*//g; s/ tsname=[^ ]*//g' "$D/$t.raw" | sort > "$D/$t.ex"
done
wc -l "$D"/*.ex
