#!/bin/bash
# r11v4 VERIFIER — rebuild every adversarial arm on REAL Surelog v1.87 goldens
# with two binaries and score the COMPARE-VISIBLE param_assign census.
#   usage: run.sh <pristine-binary> <candidate-binary> [arm-root]
# Every arm records surelog rc, `[  ERROR] : 0`, slang rc and the official
# uhdm-cmp rc + `^LHS:` head count.  LOST != 0 on any arm is a REGRESSION.
set -u
H=$(dirname "$(readlink -f "$0")")
P=$(readlink -f "${1:?pristine binary}"); Q=$(readlink -f "${2:?candidate binary}")
R=${3:-/tmp/r11v4_arms}
mkdir -p "$R"
for a in v1 v2 v3 v4 v5 v6 v7 v8 v9 v10; do
  mkdir -p "$R/$a"; cp "$H/$a/dut.sv" "$R/$a/dut.sv"
  bash "$H/armrun.sh" "$R/$a" pris "$P"
  bash "$H/armrun.sh" "$R/$a" cand "$Q"
done
echo
for a in v1 v2 v3 v4 v5 v6 v7 v8 v9 v10; do bash "$H/pascore.sh" "$R/$a" pris cand; done
