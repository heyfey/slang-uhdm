#!/bin/bash
# r11u229 (adapted from r11u222map/drivers/awaylandings.sh): the away-moved-record census of each landing under
# verification: its single-off sweep against the HEAD sweep, both record forms (canonical = the gate's uhdm-strictcmp;
# RAW=1 = strictcmp_x's raw full names), chain-keyed and flat with the in-place pairing (drivers/awayall.py), and the
# reversed positive control (HEAD as the off side).  usage: awaylandings.sh <out dir> <HEAD wd> <tag>=<off wd>...
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$R229_BIN/strictcmp_x" ] || { echo "awaylandings.sh: $R229_BIN/strictcmp_x not executable" >&2; exit 2; }
O=$1; L=$2; shift 2; mkdir -p $O; DR=$(cd "$(dirname "$0")" && pwd)
for a in "$@"; do
  tag=${a%%=*}; off=${a#*=}
  python3 $DR/awayall.py $off $L 2 > $O/away_${tag}_can.txt 2>&1
  RAW=1 python3 $DR/awayall.py $off $L 2 > $O/away_${tag}_raw.txt 2>&1
  python3 $DR/awayall.py $L $off 2 > $O/away_${tag}_REVERSED_can.txt 2>&1
  RAW=1 python3 $DR/awayall.py $L $off 2 > $O/away_${tag}_REVERSED_raw.txt 2>&1
  echo "$tag $(tail -1 $O/away_${tag}_can.txt) | RAW $(tail -1 $O/away_${tag}_raw.txt) | REVERSED $(tail -1 $O/away_${tag}_REVERSED_can.txt) | REVERSED RAW $(tail -1 $O/away_${tag}_REVERSED_raw.txt)"
done
