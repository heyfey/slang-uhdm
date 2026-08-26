#!/usr/bin/env bash
# r10earl96 -- ARM SCORER.  For ONE .sv arm: build the GOLDEN with Surelog and
# the two frozen binaries, in BOTH views, and score the PRISTINE and PATCHED
# databases against the SAME golden with ct96cen + score96.py.
# Every child gets </dev/null and its rc is printed.  MEASUREMENT ONLY.
#   usage: arm96.sh <file.sv> <outdir>
#   env:   PRISTINE_BIN PATCHED_BIN CEN96
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PRIS=${PRISTINE_BIN:?}; PAT=${PATCHED_BIN:?}; CEN=${CEN96:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
for V in plain elab; do
  EL=""; SEL=""
  [ "$V" = elab ] && { EL="-elabuhdm"; SEL="--elabuhdm"; }
  mkdir -p "$D/$V"; cp "$F" "$D/$V/"
  ( cd "$D/$V" && "$SL" -parse -nobuiltin -nocache -sv $EL -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "  $V surelog rc=$?"
  [ -f "$D/$V/slpp_all/surelog.uhdm" ] || { echo "  $V NO-GOLDEN"; continue; }
  for S in pris patc; do
    case $S in pris) BIN=$PRIS;; patc) BIN=$PAT;; esac
    mkdir -p "$D/$V/$S"; cp "$F" "$D/$V/$S/"
    ( cd "$D/$V/$S" && "$BIN" "$B" $SEL -o o.uhdm >o.log 2>&1 </dev/null ); echo "  $V $S rc=$?"
  done
  "$CEN" "$D/$V/slpp_all/surelog.uhdm" </dev/null 2>/dev/null  > "$D/$V/g.cen"
  # the OFFICIAL judge, per side (its head goes to STDERR)
  for S in pris patc; do
    [ -f "$D/$V/$S/o.uhdm" ] || continue
    "$HOME/git-repos/UHDM/build/bin/uhdm-cmp" "$D/$V/slpp_all/surelog.uhdm" "$D/$V/$S/o.uhdm" \
      >"$D/$V/$S.cmp.out" 2>"$D/$V/$S.cmp.err" </dev/null
    echo "  $V $S uhdm-cmp rc=$? headlines=$(wc -l < "$D/$V/$S.cmp.err") heads=$(grep -c '^LHS:' "$D/$V/$S.cmp.err"; true)"
  done
  for S in pris patc; do
    [ -f "$D/$V/$S/o.uhdm" ] || continue
    "$CEN" "$D/$V/$S/o.uhdm" </dev/null 2>/dev/null  > "$D/$V/$S.cen"
  done
done
# score each side against the SAME golden and print the buckets
for V in plain elab; do
  [ -f "$D/$V/g.cen" ] || continue
  for S in pris patc; do
    [ -f "$D/$V/$S.cen" ] || continue
    echo "  $V $S $(python3 "$(dirname "$0")/score96.py" "$D/$V/g.cen" "$D/$V/$S.cen" 0 </dev/null)"
  done
done
