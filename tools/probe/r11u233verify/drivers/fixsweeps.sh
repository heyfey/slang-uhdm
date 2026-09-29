#!/bin/bash
# r11u233: fixsweeps.sh <fix binary>: (1) the firing census of the fix's refinements: the full gate sweep with
# R11V233_TRACE=/tmp/r11u233_trFX (every stage; the gate dispatches every row as it mandates, nothing here reads a
# fenced row); (2) after drivers/predict233.py froze the prediction from those traces, the untraced gate sweep of the
# fix binary (/tmp/r11u233_wFX), measured against the HEAD sweep /tmp/r11u233_wON.
source "$(dirname "$0")/env.sh" || exit 2
B=$1; [ -x "$B" ] || { echo "fixsweeps.sh: $B not executable" >&2; exit 2; }
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /tmp/r11u233_trFX; mkdir -p /tmp/r11u233_trFX
bash $D/sweep.sh /tmp/r11u233_wFC "$B" R11V233_TRACE=/tmp/r11u233_trFX
python3 $D/predict233.py /tmp/r11u233_trFX /tmp/r11u233_wFC > $R233_DIR/evidence/census/predict_fix.txt
( md5sum < $R233_DIR/evidence/census/predict_fix.txt | cut -d' ' -f1; md5sum < "$B" | cut -d' ' -f1; date -u +%FT%TZ ) > $R233_DIR/evidence/census/predict_fix.stamp
bash $D/sweep.sh /tmp/r11u233_wFX "$B"
