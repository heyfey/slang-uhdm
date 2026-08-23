#!/usr/bin/env bash
# r10vearl74 — build ONE arm with Surelog (golden) and with BOTH frozen
# binaries, in BOTH views, and census each with vcen74 (judge fields + ts
# presence) and vcen74 --span (span presence, scored separately).
# MEASUREMENT ONLY.  usage: varm74.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=/tmp/v74_probe/vcen74
PRIS=/tmp/v74_bin/pris.bin; PATCHED=${PATCHED:-/tmp/v74_bin/pat.bin}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && timeout 900 "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && timeout 900 "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && timeout 900 "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && timeout 900 "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && timeout 900 "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.rg"
  "$CEN" "$D/$t.uhdm" --span 2>/dev/null > "$D/$t.sp"
  echo "$t cells=$(wc -l < "$D/$t.rg")"
done
echo "WD=$D"
