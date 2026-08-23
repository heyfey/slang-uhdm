#!/usr/bin/env bash
# r10v73 — build one arm with Surelog + both frozen binaries in both views,
# census with vcen73 (all constants, span separate) and pacen73, and run the
# OFFICIAL uhdm-cmp.  MEASUREMENT ONLY.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PRIS=/tmp/v73_bin/pris.bin; PATCHED=/tmp/v73_bin/patched.bin
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SLrc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
[ -f "$D/g.uhdm" ] || { echo "NO_GOLDEN $B"; exit 5; }
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "o rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "oe rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "q rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "qe rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  /tmp/v73_bin/vcen73  "$D/$t.uhdm" > "$D/$t.vc" 2>/dev/null
  /tmp/v73_bin/pacen73 "$D/$t.uhdm" > "$D/$t.pa" 2>/dev/null
done
for t in o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  n=$("$CMP" "$D/g.uhdm" "$D/$t.uhdm" 2>&1 | wc -l); echo "CMPLINES $t=$n"
done
echo "WD=$D"
