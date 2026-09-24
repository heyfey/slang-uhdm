#!/bin/bash
# ds_all.sh <out.jsonl> <casedirs...> : ON, A3 and the case's own switch off
source /tmp/r11u141_drv/env.sh
out=$1; shift
for c in "$@"; do
  law=$(head -1 $c/dut.sv | grep -o '§ [A-Za-z0-9]*')
  sw=$(python3 -c "import sys; sys.path.insert(0,'/tmp/r11u141_drv'); from lawmap import *; print({v[0]:v[1] for v in LAWS.values()}.get('$law','-'))")
  echo "ON - $c"; echo "A3 R11U130_OFF,R11U131_OFF,R11U134_OFF $c"; echo "OWN $sw $c"
done | xargs -P 3 -L 1 python3 /tmp/r11u141_drv/ds_case.py > $out 2>/tmp/r11u141_ds_err.log
