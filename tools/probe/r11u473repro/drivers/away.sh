#!/bin/bash
# away.sh <list> <out>: pristine and law6 on each case dir, then the overlap census
cd /tmp/wt_r11u473/tools/probe
while read -u 3 c; do
  bash /tmp/r11u473_drv/runcase.sh /tmp/r11u473_bin/pristine pris "$c" </dev/null
  bash /tmp/r11u473_drv/runcase.sh /tmp/r11u473_bin/law6 law6 "$c" </dev/null
  python3 /tmp/r11u473_drv/overlap.py /tmp/r11u473_runs$(realpath "$c" | sed 's#/$##') pris law6
done 3< "$1" > "$2" 2>&1
echo DONE >> "$2"
