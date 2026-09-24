#!/bin/bash
# ds_all.sh <out.jsonl>: every fresh case under ON, its own law off (OWN), the three landings off (A3); one worker
cd $(dirname $0)/..; source drivers/env.sh
A3=R11U133_OFF,R11V141_OFF,R11U137_OFF,R11U139_OFF,R11V137_OFF
for c in $(ls -d $PWD/cases/*/*); do
  g=$(basename $(dirname $c)); sw=$(python3 -c "import sys; sys.path.insert(0,'drivers'); from lawmap import M; print(M['$g'][1])")
  python3 drivers/ds_case.py ON - $c; python3 drivers/ds_case.py OWN $sw $c; python3 drivers/ds_case.py A3 $A3 $c
done > $1 2>/dev/null
