#!/bin/bash
# gridall.sh <out> [--el] : grid.py over every case dir (3 at a time), one output file per mode.
source /tmp/wt_r11u177/tools/probe/r11u177verify/drivers/env.sh || exit 2
out=$1; shift
find /tmp/wt_r11u177/tools/probe/r11u177verify/cases -mindepth 2 -maxdepth 2 -type d | sort | \
  xargs -P ${GP:-3} -I{} python3 /tmp/wt_r11u177/tools/probe/r11u177verify/drivers/grid.py "$@" {} > $out 2>&1
