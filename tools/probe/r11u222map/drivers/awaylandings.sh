#!/bin/bash
# r11u222map: the away-moved-record census of every landing since map 13 (section 8): each landing-off state sweep
# ($SWPFX<k>, statesweeps.sh) against the pristine HEAD sweep ($SP), both record forms (canonical = the gate's
# uhdm-strictcmp; RAW=1 = strictcmp_x's raw full names), chain-keyed and flat with the in-place pairing (awayall.py);
# then the r11u218 law sweep ($LSW) against $SP and the reversed positive control.  One job at a time (memory).
# usage: awaylandings.sh <k>...   env: SWPFX SP LSW (and env.sh's)
. "$(dirname "$0")/env.sh"
O=$W/away; mkdir -p $O
for s in "$@"; do
  case $s in
    L) off=$SP; on=$LSW; tag=law218 ;;
    RL) off=$LSW; on=$SP; tag=REVERSED_law218 ;;
    R*) off=$SP; on=${SWPFX}${s#R}; tag=REVERSED_${s#R} ;;
    *) off=${SWPFX}$s; on=$SP; tag=$s ;;
  esac
  python3 $DR/awayall.py $off $on 1 > $O/away_${tag}_can.txt 2>&1
  RAW=1 python3 $DR/awayall.py $off $on 1 > $O/away_${tag}_raw.txt 2>&1
  echo "$tag $(tail -1 $O/away_${tag}_can.txt) | RAW $(tail -1 $O/away_${tag}_raw.txt)"
done
