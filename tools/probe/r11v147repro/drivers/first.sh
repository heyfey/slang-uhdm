#!/bin/bash
# first.sh <corpus> <mode> <test> [N]: first N strict records, pristine vs law sweep dbs
c=$1; m=$2; t=$3; N=${4:-1}
for w in /tmp/v11u147_wdP /tmp/v11u147_wdL ${EXTRA_WD}; do d=$(ls -d $w/$c/$m/$t-* 2>/dev/null | head -1); [ -z "$d" ] && { echo "$w: none"; continue; }
  g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1); g=/home/heyfey/.cache/slang-uhdm-$g/golden.uhdm
  echo "== $w $(grep -o 'slang: *[^ ]*' $d/cmds.txt | awk '{print $2}')"; /tmp/v11u147_bin/strictcmp --max $N $g $d/slang.uhdm 2>&1 | tail -$((3*N+2)); done
