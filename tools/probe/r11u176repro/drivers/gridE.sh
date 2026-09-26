#!/bin/bash
# gridE.sh <tag> <binary> : drivers/grid.sh in the --elabuhdm form (drivers/caseE.sh: Surelog -elabuhdm, ours --elabuhdm).
set -u; . /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/env.sh
TAG=$1 BIN=$2
find /tmp/wt_r11u176/tools/probe/r11u176repro/cases -name dut.sv -printf '%h\n' | sort | \
  OUT=/tmp/r11u176_scratch/gridoutE TAG=$TAG xargs -P 4 -I{} /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/caseE.sh {} $BIN 2>&1 | \
  sed 's|/tmp/wt_r11u176/tools/probe/r11u176repro/cases/||' | awk '{printf "%s %s %s %s %s\n", $1, $4, $5, $6, $7}' | sort
