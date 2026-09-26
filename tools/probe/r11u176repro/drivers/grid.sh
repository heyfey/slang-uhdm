#!/bin/bash
# grid.sh <tag> <binary> [ENV=VAL ...] : run every case of cases/ (drivers/case.sh: goldens from the pinned Surelog,
# content-keyed cache) with the binary and the given environment; prints one verdict line per case, sorted.
set -u; . /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/env.sh
TAG=$1 BIN=$2; shift 2
find /tmp/wt_r11u176/tools/probe/r11u176repro/cases -name dut.sv -printf '%h\n' | sort | \
  env "$@" OUT=/tmp/r11u176_scratch/gridout TAG=$TAG xargs -P 4 -I{} /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/case.sh {} $BIN 2>&1 | \
  sed 's|/tmp/wt_r11u176/tools/probe/r11u176repro/cases/||' | awk '{printf "%s %s %s %s %s\n", $1, $4, $5, $6, $7}' | sort
