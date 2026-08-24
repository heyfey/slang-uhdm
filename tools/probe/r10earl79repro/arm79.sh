#!/usr/bin/env bash
# r10earl79 — build ONE arm with Surelog (golden) and with the frozen binaries
# (pristine / patched / NEUTRAL = patched with the law's A/B gate off), in both
# views, and census every result with rngcen79.  MEASUREMENT ONLY.
#   usage: RNGCEN79=.. PRIS=.. [PATCHED=..] arm79.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${RNGCEN79:?set RNGCEN79}
PRIS=${PRIS:?}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
if [ -n "$PATCHED" ]; then
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
( cd "$D" && R10E79_OFF=1 "$PATCHED" "$B" -o n.uhdm >n.log 2>&1 </dev/null ); echo "neutr rc=$?"
fi
for t in g o oe q qe n; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.rg"
  echo "$t cells=$(wc -l < "$D/$t.rg")"
done
echo "WD=$D"
