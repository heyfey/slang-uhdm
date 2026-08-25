#!/usr/bin/env bash
# r10earl92 — build ONE grid arm with Surelog (GOLDEN) and with the TWO FROZEN
# binaries, census all three with ct92cen, and print one line per CELL.
# MEASUREMENT ONLY; the official uhdm-cmp stays the judge on the corpus.
#   usage: arm92.sh <file.sv> <outdir>
#   env:   SURELOG PRIS PATCHED CEN92 [SLFLAGS] [ELAB=1]
# Every child gets </dev/null and its rc is RECORDED (an rc=139 that leaves a
# short .uhdm behind must never read as "no difference").
# NOTE: the golden-producing Surelog is ~/git-repos/Surelog/build/bin/surelog —
# the sv-tests copy writes a UHDM the installed reader decodes with EVERY
# relation NULL, which reads as "no cells" instead of as an error.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN92:?set CEN92}
PRIS=${PRIS:?}; PATCHED=${PATCHED:-$PRIS}
SLFLAGS=${SLFLAGS:-}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
EL=""; [ "${ELAB:-0}" = 1 ] && EL="-elabuhdm"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv $EL -d uhdm $SLFLAGS "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
SEL=""; [ "${ELAB:-0}" = 1 ] && SEL="--elabuhdm"
( cd "$D" && "$PRIS"    "$B" $SEL -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" $SEL -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: golden=$(wc -l < "$D/g.rows") pris=$(wc -l < "$D/o.rows") patched=$(wc -l < "$D/q.rows")"
