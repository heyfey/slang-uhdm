#!/bin/bash
# r11u63 KEYED CENSUS — the hier_path SHAPE LISTER (hpgrid63) over a named set
# of arms, CALIBRATED golden-vs-golden first on every arm, then
# golden-vs-pristine and golden-vs-law.  Scores TO-GOLDEN / AWAY-GOLDEN.
#
#   census63.sh <mode> <lawWorkdir> <prisWorkdir> <names.txt> <outdir>
#
# Every workdir is a PARAMETER.  The golden database is read out of each arm's
# OWN cmds.txt, so this cannot compare against the wrong golden, and a missing
# side is printed and COUNTED rather than read as perfection.
set -u
MODE=${1:?mode}; LAW=${2:?lawwd}; PRIS=${3:?priswd}; NAMES=${4:?names}; OUT=${5:?outdir}
L=${HPGRID63:-/tmp/r11u63_probe/hpgrid63}
[ -x "$L" ] || { echo "FATAL: no hpgrid63 at $L"; exit 3; }
mkdir -p "$OUT" || exit 1
scored=0; skipped=0; calibbad=0; tog=0; awayg=0; samecnt=0
while read -r n; do
  [ -n "$n" ] || continue
  dp=$(ls -d "$PRIS/$MODE/$n"-*/ 2>/dev/null | head -1)
  dl=$(ls -d "$LAW/$MODE/$n"-*/ 2>/dev/null | head -1)
  if [ -z "$dp" ] || [ -z "$dl" ]; then echo "SKIP-NODIR $n"; skipped=$((skipped+1)); continue; fi
  g=$(grep -o '/[^ )]*slang-uhdm-goldens/[^ )]*' "$dp/cmds.txt" | head -1)
  [ -d "$g" ] && g="$g/golden.uhdm"
  if [ ! -f "$g" ] || [ ! -f "$dp/slang.uhdm" ] || [ ! -f "$dl/slang.uhdm" ]; then
    echo "SKIP-NOFILE $n"; skipped=$((skipped+1)); continue; fi
  c=$("$L" --rows "$g" "$g" | tail -1)
  cd_=$(echo "$c" | sed -E 's/.* DIFF ([0-9]+) .*/\1/')
  if [ "$cd_" != "0" ]; then echo "CALIB-BAD $n : $c"; calibbad=$((calibbad+1)); continue; fi
  p=$("$L" "$g" "$dp/slang.uhdm" | tail -1)
  w=$("$L" "$g" "$dl/slang.uhdm" | tail -1)
  pd=$(echo "$p" | sed -E 's/.* DIFF ([0-9]+) .*/\1/')
  wd=$(echo "$w" | sed -E 's/.* DIFF ([0-9]+) .*/\1/')
  scored=$((scored+1))
  printf "%-40s calib[%s]  PRIS[%s]  LAW[%s]\n" "$n" "$c" "$p" "$w"
  "$L" "$g" "$dl/slang.uhdm" > "$OUT/$n.law.txt" 2>&1
  "$L" "$g" "$dp/slang.uhdm" > "$OUT/$n.pris.txt" 2>&1
  if [ "$wd" -lt "$pd" ]; then tog=$((tog+1));
  elif [ "$wd" -gt "$pd" ]; then awayg=$((awayg+1)); echo "  *** AWAY-GOLDEN $n $pd -> $wd";
  else samecnt=$((samecnt+1)); fi
done < "$NAMES"
echo "CENSUS mode=$MODE scored=$scored skipped=$skipped calib-bad=$calibbad TO-GOLDEN=$tog AWAY-GOLDEN=$awayg UNCHANGED=$samecnt"
