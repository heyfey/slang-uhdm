#!/usr/bin/env bash
# r10earl89 — build ONE arm with Surelog (GOLDEN) and with the frozen binaries
# (pristine / patched / NEUTRAL = patched with R10E89_OFF=1), in BOTH VIEWS,
# and census every result with dimts89.  MEASUREMENT ONLY: the official
# uhdm-cmp stays the sole judge.  Every child gets </dev/null and its rc is
# recorded (RESUME §9: a rc=139 wears the last stderr warning otherwise).
#   usage: DIMTS89=.. PRIS=.. [PATCHED=..] arm89.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${DIMTS89:?set DIMTS89}
PRIS=${PRIS:?}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SLdef  rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache $LANG_FLAG "$B" >sle.log 2>&1 </dev/null ); echo "SLelab rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris   rc=$?"
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE  rc=$?"
if [ -n "$PATCHED" ]; then
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc   rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE  rc=$?"
( cd "$D" && R10E89_OFF=1 "$PATCHED" "$B"            -o n.uhdm  >n.log  2>&1 </dev/null ); echo "neutr  rc=$?"
( cd "$D" && R10E89_OFF=1 "$PATCHED" "$B" --elabuhdm -o ne.uhdm >ne.log 2>&1 </dev/null ); echo "neutrE rc=$?"
fi
for t in g ge o oe q qe n ne; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.rg"
  echo "$t cells=$(wc -l < "$D/$t.rg")"
done
echo "WD=$D"
