#!/usr/bin/env bash
# run_v112.sh — r10uvm112 VERIFIER arm driver.
#   usage: PRIS=<pristine bin> SHIP=<patched bin> OUT=<dir> ./run_v112.sh <src> [more srcs]
# Builds golden (Surelog), pristine and patched databases for ONE arm in BOTH
# views, records rc PER CELL, and judges each side with the OFFICIAL uhdm-cmp
# (LHS = golden always).  Scratch is keyed on the RELATIVE first source path so
# two arms with the same basename in different directories cannot collide.
set -u
SU=${SU:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
ROOT=${ROOT:-$(cd "$(dirname "$0")" && pwd)}
OUT=${OUT:?set OUT}
TAG=${TAG:-}
ARM=$1
BASE=$(echo "${TAG:-$ARM}" | sed 's#[^A-Za-z0-9._-]#_#g')
SRCS="$*"
INC=""; SINC=""
case "$ARM" in */*) INC="-I$ROOT/$(dirname "$ARM")"; SINC="+incdir+$ROOT/$(dirname "$ARM")";; esac
for view in def elab; do
  W=$OUT/$BASE.$view
  rm -rf "$W"; mkdir -p "$W"
  if [ "$view" = elab ]; then SUF="-elabuhdm"; SLF="--elabuhdm"; else SUF=""; SLF=""; fi
  ( cd "$ROOT" && $SU -parse $SUF $INC $SRCS -mt 0 -mp 0 -o "$W" > "$W/su.log" 2>&1 </dev/null ); surc=$?
  G=$(find "$W" -name 'surelog.uhdm' | head -1)
  [ -n "$G" ] && cp "$G" "$W/golden.uhdm"
  ( cd "$ROOT" && "${PRIS:?}" $SINC $SRCS --single-unit $SLF -o "$W/pris.uhdm" > "$W/pris.log" 2>&1 </dev/null ); prc=$?
  ( cd "$ROOT" && "${SHIP:?}" $SINC $SRCS --single-unit $SLF -o "$W/ship.uhdm" > "$W/ship.log" 2>&1 </dev/null ); src=$?
  pl=-; ph=-; sl=-; sh=-; pc=-; sc=-
  if [ -f "$W/golden.uhdm" ] && [ -f "$W/pris.uhdm" ]; then
    "$CMP" "$W/golden.uhdm" "$W/pris.uhdm" > "$W/cmp.pris.txt" 2>&1; pc=$?
    pl=$(wc -l < "$W/cmp.pris.txt"); ph=$(grep -c '^LHS:' "$W/cmp.pris.txt"; true)
  fi
  if [ -f "$W/golden.uhdm" ] && [ -f "$W/ship.uhdm" ]; then
    "$CMP" "$W/golden.uhdm" "$W/ship.uhdm" > "$W/cmp.ship.txt" 2>&1; sc=$?
    sl=$(wc -l < "$W/cmp.ship.txt"); sh=$(grep -c '^LHS:' "$W/cmp.ship.txt"; true)
  fi
  for f in golden pris ship; do
    [ -f "$W/$f.uhdm" ] && "$DUMP" "$W/$f.uhdm" 2>/dev/null </dev/null > "$W/$f.dump"
  done
  printf "ARM %-22s %-4s rc(su=%s pris=%s ship=%s) golden=%s | PRIS lines=%s heads=%s rc=%s | SHIP lines=%s heads=%s rc=%s\n" \
    "$BASE" "$view" "$surc" "$prc" "$src" "${G:+yes}" "$pl" "$ph" "$pc" "$sl" "$sh" "$sc"
done
