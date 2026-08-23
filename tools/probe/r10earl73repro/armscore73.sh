#!/usr/bin/env bash
# r10earl73 — ADJUDICATE one boundary arm: build it with Surelog (golden) and
# with both FROZEN binaries in BOTH views, then score
#   (1) the OFFICIAL uhdm-cmp line count, pristine vs patched (the judge), and
#   (2) the param_assign value-encoding census, 3-way (base/ours/golden).
# A moved arm is acceptable only if the judge does not get worse and the census
# shows AWAY-GOLDEN 0.
# MEASUREMENT ONLY.  usage: PRIS=.. PATCHED=.. PACEN73=.. armscore73.sh <file> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CEN=${PACEN73:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
MS=$(dirname "$0")/msjoin73.py
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null )
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
[ -f "$D/g.uhdm" ] || { echo "NO_GOLDEN $B"; exit 5; }
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null )
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null )
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null )
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null )
for t in o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  n=$("$CMP" "$D/g.uhdm" "$D/$t.uhdm" 2>&1 | wc -l)
  echo "CMPLINES $t=$n"
  "$CEN" "$D/$t.uhdm" > "$D/$t.pa" 2>/dev/null
done
"$CEN" "$D/g.uhdm" > "$D/g.pa" 2>/dev/null
echo "-- plain view census:"    ; python3 "$MS" "$D/g.pa" "$D/q.pa"  --base "$D/o.pa"  2>/dev/null | head -6
echo "-- elabuhdm view census:" ; python3 "$MS" "$D/g.pa" "$D/qe.pa" --base "$D/oe.pa" 2>/dev/null | head -6
