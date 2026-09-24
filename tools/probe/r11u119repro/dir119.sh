#!/usr/bin/env bash
# r11u119 mover DIRECTION: for every mover (a byteverify MOVER list), the
# order-blind locdump rows (--val) on which golden and the database differ,
# pristine vs law.  TOWARD = rows fixed, AWAY = rows the law database differs
# from golden on that the pristine one did not.  AWAY must be 0 (or a named coin).
#   dir119.sh <movers.txt> <law wd> <pristine wd> <downstream|corpus>
set -u
LD=${LOCDUMP:-/tmp/r11u119_scr/locdump}
while read -r m; do
  if [ "$4" = downstream ]; then
    g=$(python3 "$(dirname "$0")/sdb119.py" "$m" 2>/dev/null | awk '{print $2}')
  else
    g=$(grep -o 'golden cache hit [^)]*' "$3/$m/cmds.txt" | awk '{print $4}')/golden.uhdm
  fi
  [ -f "$g" ] || { echo "$m NOGOLDEN"; continue; }
  "$LD" "$g" --val | sed 's#/[^ ]*/##' | sort > ${TMPDIR:-/tmp}/r11u119_dir_g
  "$LD" "$3/$m/slang.uhdm" --val | sort > ${TMPDIR:-/tmp}/r11u119_dir_p
  "$LD" "$2/$m/slang.uhdm" --val | sort > ${TMPDIR:-/tmp}/r11u119_dir_l
  dp=$(comm -3 ${TMPDIR:-/tmp}/r11u119_dir_g ${TMPDIR:-/tmp}/r11u119_dir_p | sort); dl=$(comm -3 ${TMPDIR:-/tmp}/r11u119_dir_g ${TMPDIR:-/tmp}/r11u119_dir_l | sort)
  tow=$(comm -23 <(echo "$dp") <(echo "$dl") | grep -c .); away=$(comm -13 <(echo "$dp") <(echo "$dl") | grep -c .)
  echo "$m TOWARD=$tow AWAY=$away"
done < "$1"
