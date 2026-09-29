#!/bin/bash
# r11u230map: the away-moved-record census of every landing since map 14 (section 9): each landing-off state sweep
# ($SWPFX<k>: the HEAD binary under that landing's switches, statesweeps.sh) against this map's pristine HEAD sweep ($SP),
# both record forms (canonical = the gate's uhdm-strictcmp; RAW=1 = strictcmp_x's raw full names), chain-keyed and flat
# with the position-aware pairing (awayall.py); R<k> = the reversed positive control (HEAD as the off side).
# One job at a time (memory).   usage: awaylandings.sh <k>...   env: SWPFX SP (and env.sh's)
. "$(dirname "$0")/env.sh"
[ -x "$STRICT_CMP" ] && [ -x "$B/strictcmp_x" ] || { echo "awaylandings.sh: comparators not executable" >&2; exit 2; }
O=$W/away; mkdir -p $O
for s in "$@"; do
  case $s in
    R*) off=$SP; on=${SWPFX:?}${s#R}; tag=REVERSED_${s#R} ;;
    *) off=${SWPFX:?}$s; on=${SP:?}; tag=$s ;;
  esac
  python3 $DR/awayall.py $off $on 2 > $O/away_${tag}_can.txt 2>&1
  RAW=1 python3 $DR/awayall.py $off $on 2 > $O/away_${tag}_raw.txt 2>&1
  echo "$tag $(tail -1 $O/away_${tag}_can.txt) | RAW $(tail -1 $O/away_${tag}_raw.txt)"
done
