#!/usr/bin/env bash
# v106run.sh <arm> [extra srcs...] : build golden + pris + ship in BOTH views.
# rc per cell.  Scratch keyed on the RELATIVE arm path under $VWD.
set -u
SU=${SU:-$HOME/git-repos/Surelog/build/bin/surelog}
ROOT=${ROOT:?}; VWD=${VWD:?}
PRIS=${PRIS:?}; SHIP=${SHIP:?}
ARM=$1; shift
SRCS="$ARM $*"
BASE=$(echo "$ARM" | sed 's#[^A-Za-z0-9._-]#_#g')
for view in def elab; do
  W=$VWD/$BASE.$view
  rm -rf "$W"; mkdir -p "$W" || exit 9
  if [ "$view" = elab ]; then SUF="-elabuhdm"; SLF="--elabuhdm"; else SUF=""; SLF=""; fi
  ( cd "$ROOT" && $SU -parse $SUF $SRCS -mt 0 -mp 0 -o "$W" > "$W/su.log" 2>&1 ); surc=$?
  G=$(find "$W" -name 'surelog.uhdm' | head -1)
  [ -n "$G" ] && cp "$G" "$W/golden.uhdm"
  ( cd "$ROOT" && $PRIS $SRCS --single-unit $SLF -o "$W/pris.uhdm" > "$W/pris.log" 2>&1 ); prc=$?
  ( cd "$ROOT" && $SHIP $SRCS --single-unit $SLF -o "$W/ship.uhdm" > "$W/ship.log" 2>&1 ); src=$?
  echo "RC $BASE.$view surelog=$surc pris=$prc ship=$src golden=${G:+YES}${G:-NONE}"
done
