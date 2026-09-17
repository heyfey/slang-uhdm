#!/usr/bin/env bash
# r11u64 KEYED CENSUS with the SHAPE LISTER beside it.
# For each named arm: CALIBRATE golden-vs-golden FIRST (must read DIFF 0), then
# score golden-vs-PRISTINE and golden-vs-LAW with pgrid64, and report
# TO-GOLDEN / AWAY-GOLDEN / UNCHANGED per arm.  Each arm's golden is read out of
# its OWN cmds.txt, never guessed.
#   usage: census64.sh <prisWorkdir> <lawWorkdir> <mode> <namesFile> <pgrid64>
set -u
PW=$1; LW=$2; MODE=$3; NAMES=$4; PG=$5
tog=0; away=0; unch=0; cal=0; calbad=0; scored=0
while read -r name; do
  [ -z "$name" ] && continue
  pd=$(ls -d "$PW/$MODE/$name"-* 2>/dev/null | head -1)
  ld=$(ls -d "$LW/$MODE/$name"-* 2>/dev/null | head -1)
  [ -n "$pd" ] && [ -f "$pd/slang.uhdm" ] || { echo "SKIP-NODB  $MODE $name"; continue; }
  [ -n "$ld" ] && [ -f "$ld/slang.uhdm" ] || { echo "SKIP-NODB  $MODE $name"; continue; }
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$pd/cmds.txt" | head -1)
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || { echo "SKIP-NOGOLD $MODE $name"; continue; }
  c=$("$PG" --rows "$g/golden.uhdm" "$g/golden.uhdm" 2>/dev/null | tail -1)
  cd0=$(echo "$c" | grep -o 'DIFF [0-9]*' | grep -o '[0-9]*')
  if [ "${cd0:-x}" = "0" ]; then cal=$((cal+1)); else calbad=$((calbad+1)); echo "CALIB-FAIL $MODE $name : $c"; continue; fi
  p=$("$PG" "$g/golden.uhdm" "$pd/slang.uhdm" 2>/dev/null | tail -1)
  l=$("$PG" "$g/golden.uhdm" "$ld/slang.uhdm" 2>/dev/null | tail -1)
  pd0=$(echo "$p" | grep -o 'DIFF [0-9]*' | grep -o '[0-9]*')
  ld0=$(echo "$l" | grep -o 'DIFF [0-9]*' | grep -o '[0-9]*')
  scored=$((scored+1))
  if [ "$ld0" -lt "$pd0" ]; then tog=$((tog+1)); v=TO-GOLDEN
  elif [ "$ld0" -gt "$pd0" ]; then away=$((away+1)); v=AWAY-GOLDEN
  else unch=$((unch+1)); v=UNCHANGED; fi
  echo "$v  $MODE $name  rows=$(echo "$p" | grep -o 'ROWS [0-9]*')  PRIS-DIFF=$pd0 LAW-DIFF=$ld0"
done < "$NAMES"
echo "CENSUS $MODE scored=$scored calib-ok=$cal calib-bad=$calbad TO-GOLDEN=$tog AWAY-GOLDEN=$away UNCHANGED=$unch"
