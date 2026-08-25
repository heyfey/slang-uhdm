#!/usr/bin/env bash
# v136 WIDE differential boundary: every probe .sv, both views, both binaries.
# Prints one row per (file, view): rc and md5 for pristine and patched.
set -u
PRIS=${PRIS:?set PRIS}; PAT=${PATCHED:?set PATCHED}
ROOT=${PROBE_ROOT:?set PROBE_ROOT (a tools/probe-bearing tree)}
REL="$1"
SAFE=$(echo "$REL" | tr '/' '_')
D=${SCRATCH:-/tmp/r10v136_bnd}/$SAFE; mkdir -p "$D"
F="$ROOT/$REL"
for view in def elab; do
  FLAG=""; [ "$view" = elab ] && FLAG="--elabuhdm"
  ( cd "$(dirname "$F")" && "$PRIS" "$(basename "$F")" --nobuiltin $FLAG -o "$D/o_$view.uhdm" >"$D/o_$view.log" 2>&1 </dev/null ); rcp=$?
  ( cd "$(dirname "$F")" && "$PAT"  "$(basename "$F")" --nobuiltin $FLAG -o "$D/q_$view.uhdm" >"$D/q_$view.log" 2>&1 </dev/null ); rcq=$?
  mo=$( [ -f "$D/o_$view.uhdm" ] && md5sum "$D/o_$view.uhdm" | cut -c1-32 || echo NONE )
  mq=$( [ -f "$D/q_$view.uhdm" ] && md5sum "$D/q_$view.uhdm" | cut -c1-32 || echo NONE )
  st=SAME; [ "$mo" != "$mq" ] && st=MOVED; [ "$rcp" != "$rcq" ] && st=RC-DIFF
  echo -e "$REL\t$view\trc_p=$rcp\trc_q=$rcq\t$st"
  rm -f "$D/o_$view.uhdm" "$D/q_$view.uhdm"
done
