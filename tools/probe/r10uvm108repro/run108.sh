#!/bin/bash
# run108.sh <arm.sv> [extra srcs] : golden + pris (+ ship if SHIP set), BOTH views.
# rc recorded per cell.  Scratch keyed on the RELATIVE arm path.
set -u
SU=${SU:-$HOME/git-repos/Surelog/build/bin/surelog}
ROOT=${ROOT:-$(cd "$(dirname "$0")" && pwd)}
ARM=$1; shift
BASE=$(echo "$ARM" | sed 's#[/.]#_#g')
SRCS="$ARM $*"
for view in def elab; do
  W=$ROOT/run/$BASE.$view
  rm -rf "$W"; mkdir -p "$W"
  if [ "$view" = elab ]; then SUF="-elabuhdm"; SLF="--elabuhdm"; else SUF=""; SLF=""; fi
  ( cd "$ROOT" && $SU -parse $SUF $SRCS -mt 0 -mp 0 -o "$W" > "$W/su.log" 2>&1 ); surc=$?
  G=$(find "$W" -name 'surelog.uhdm' | head -1)
  ( cd "$ROOT" && ${PRIS:?set PRIS to the pristine binary} $SRCS --single-unit $SLF -o "$W/pris.uhdm" > "$W/pris.log" 2>&1 ); prc=$?
  src=NA
  if [ -n "${SHIP:-}" ]; then
    ( cd "$ROOT" && $SHIP $SRCS --single-unit $SLF -o "$W/ship.uhdm" > "$W/ship.log" 2>&1 ); src=$?
  fi
  echo "RC $BASE.$view surelog=$surc pris=$prc ship=$src golden=${G:-NONE}"
  [ -n "$G" ] && cp "$G" "$W/golden.uhdm"
done
