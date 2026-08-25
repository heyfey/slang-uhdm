#!/usr/bin/env bash
# r10v93 (adversarial verifier of r10earl93) -- build ONE arm three ways
# (Surelog GOLDEN, the frozen PRISTINE binary, the frozen PATCHED binary), plus
# the R10E93_OFF=1 A/B control, all in ONE directory so the .uhdm's embedded
# source path cannot differ between the three.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance judge.
#
#   usage: armv93.sh <file.sv> <outdir>
#   env:   PRIS PATCHED CEN93 [SURELOG]
#
# TRAP THIS SCRIPT EXISTS FOR: running the three binaries in three DIFFERENT
# directories makes every database differ (the dump embeds the source path), so
# an A/B control run that way reads "NO" on a perfectly neutral binary.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN93:?set CEN93 to a ct93cen binary}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv -elabuhdm -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o o.uhdm   >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o q.uhdm   >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && R10E93_OFF=1 "$PATCHED" "$B" --elabuhdm -o off.uhdm >off.log 2>&1 </dev/null ); echo "off   rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
if cmp -s "$D/off.uhdm" "$D/o.uhdm"; then echo "AB    R10E93_OFF=1 == PRISTINE byte for byte"
else echo "AB    R10E93_OFF=1 DIFFERS FROM PRISTINE -- the A/B gate is broken"; fi
for t in g o q; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: golden=$(wc -l < "$D/g.rows") pris=$(wc -l < "$D/o.rows") patched=$(wc -l < "$D/q.rows")"
