#!/bin/bash
# run102.sh <arm.sv> [<extra-sources>...] : builds golden+pris+ship in BOTH views
# and scores.  Every cell records rc.  Keyed on the RELATIVE arm path.
set -u
SU=${SU:-$HOME/git-repos/Surelog/build/bin/surelog}
ARM=$1; shift
BASE=$(basename "$ARM" .sv)
ROOT=${ROOT:-/tmp/v102_arms}
SRCS="$ARM $*"
for view in def elab; do
  W=$ROOT/run/$BASE.$view
  rm -rf "$W"; mkdir -p "$W"
  if [ "$view" = elab ]; then SUF="-elabuhdm"; SLF="--elabuhdm"; else SUF=""; SLF=""; fi
  ( cd "$ROOT" && $SU -parse $SUF $SRCS -mt 0 -mp 0 -o "$W" > "$W/su.log" 2>&1 ); surc=$?
  G=$(find "$W" -name 'surelog.uhdm' | head -1)
  ( cd "$ROOT" && ${PRIS:-/tmp/v102_bin/pris.bin} $SRCS --single-unit $SLF -o "$W/pris.uhdm" > "$W/pris.log" 2>&1 ); prc=$?
  ( cd "$ROOT" && ${SHIP:-/tmp/v102_bin/ship.bin} $SRCS --single-unit $SLF -o "$W/ship.uhdm" > "$W/ship.log" 2>&1 ); src=$?
  echo "RC $BASE.$view surelog=$surc pris=$prc ship=$src golden=${G:-NONE}"
  if [ -z "$G" ] || [ ! -f "$W/pris.uhdm" ] || [ ! -f "$W/ship.uhdm" ]; then
    echo "ARM $BASE.$view: SKIP-NOFILE"; continue
  fi
  if cmp -s "$W/pris.uhdm" "$W/ship.uhdm"; then BID=BYTE_IDENTICAL; else BID=BYTE_MOVED; fi
  echo "BYTES $BASE.$view $BID"
  python3 $ROOT/score102.py "$G" "$W/pris.uhdm" "$W/ship.uhdm" "$BASE.$view"
done
