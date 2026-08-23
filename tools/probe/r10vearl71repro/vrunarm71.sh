#!/usr/bin/env bash
# r10v71 verifier — build ONE arm with Surelog (golden) + frozen pristine +
# frozen patched, both views; census each.  MEASUREMENT ONLY.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${TSCEN71:?set TSCEN71 to a built r10earl71repro/tscen71}
PRIS=${PRIS:?set PRIS to the frozen pristine binary}
PATCHED=${PATCHED:?set PATCHED to the frozen patched binary}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }
  R66_INST=1 "$CEN" "$D/$t.uhdm" > "$D/$t.raw" 2>/dev/null
  # judge-fields payload: NO span, NO tsspan, NO actual-fullname; tsname KEPT
  sed 's/ span=[^ ]*//g; s/ tsspan=[^ ]*//g; s/ afn=[^ ]*//g' "$D/$t.raw" | sort > "$D/$t.ex"
  # span-PRESENCE payload: span coordinates collapsed to LOC / NOLOC
  sed 's/ span=-:0:0-0:0/ spanP=NOLOC/g; s/ span=[^ ]*/ spanP=LOC/g; s/ tsspan=-:0:0-0:0/ tsP=NOLOC/g; s/ tsspan=[^ ]*/ tsP=LOC/g; s/ afn=[^ ]*//g' "$D/$t.raw" | sort > "$D/$t.sp"
done
wc -l "$D"/*.ex 2>/dev/null
