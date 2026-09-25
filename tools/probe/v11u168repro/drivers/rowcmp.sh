#!/bin/bash
# rowcmp.sh <corpus> <mode> <name>: strict field summary pris vs law (non-fenced rows only)
[ -n "$FENCED" ] || { echo "FENCED unset"; exit 2; }
echo "$3" | grep -qwE "$FENCED" && { echo "fenced: refuse"; exit 2; }
SC=/tmp/v11u168_bin/uhdm-strictcmp
for t in P L; do
  d=$(ls -d /tmp/v11u168_sw$t/$1/$2/$3-*/ | head -1)
  g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
  gu=$(ls $g/*.uhdm 2>/dev/null | head -1)
  $SC --max ${MAX:-3} $gu $d/slang.uhdm > /tmp/v11u168_rc_$t.txt 2>&1
  echo "$t: $(grep -E '^fields' /tmp/v11u168_rc_$t.txt) | $(tail -1 /tmp/v11u168_rc_$t.txt)"
done
