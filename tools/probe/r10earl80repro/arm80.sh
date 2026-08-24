#!/usr/bin/env bash
# r10earl80 — build ONE arm with Surelog (golden) and with the frozen binaries,
# in both views, and census every result with pacen80.  MEASUREMENT ONLY.
#   usage: PACEN80=.. PRIS=.. [PATCHED=..] arm80.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${PACEN80:?set PACEN80}
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
( cd "$D" && R10E80_OFF=1 "$PATCHED" "$B" -o n.uhdm >n.log 2>&1 </dev/null ); echo "neutr rc=$?"
fi
for t in g o oe q qe n; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.pa"
  echo "$t cells=$(wc -l < "$D/$t.pa")"
done
echo "WD=$D"
