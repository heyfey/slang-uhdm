#!/bin/bash
# r11u7 — rebuild every arm's REAL Surelog v1.87 golden and score the
# COMPARE-VISIBLE param_assign census of two binaries against it.
#   usage: run.sh <pristine-binary> <candidate-binary> [arm-root]
# A LOST line on any arm is a REGRESSION.  Every arm records surelog rc,
# `[  ERROR] : 0`, slang rc, the official uhdm-cmp rc and its `^LHS:` head
# count (ARMS.run.txt); the scores come from pacen7.py, which reads only
# fields a generated Compare reads.
set -u
H=$(dirname "$(readlink -f "$0")")
P=$(readlink -f "${1:?pristine binary}"); Q=$(readlink -f "${2:?candidate binary}")
R=${3:-/tmp/r11u7_arms}
ARMS="h1 h2 h3 h4 h5"
mkdir -p "$R"
for a in $ARMS; do
  mkdir -p "$R/$a"; cp "$H/$a/dut.sv" "$R/$a/dut.sv"
  bash "$H/armrun.sh" "$R/$a" pris "$P"
  bash "$H/armrun.sh" "$R/$a" pat  "$Q"
done
echo
for a in $ARMS; do
  echo "=== $a ==="
  python3 "$H/pacen7.py" "$R/$a/w_pris/golden.dump" \
      "$R/$a/w_pris/ours.dump" "$R/$a/w_pat/ours.dump" |
    grep -E 'golden rows|agree|LOST|GAIN'
done
echo
echo "--- SCORER POSITIVE CONTROL (arguments swapped: every gaining arm must LOSE)"
for a in $ARMS; do
  printf '%s ' "$a"
  python3 "$H/pacen7.py" "$R/$a/w_pris/golden.dump" \
      "$R/$a/w_pat/ours.dump" "$R/$a/w_pris/ours.dump" | grep -E '^  LOST [0-9]'
done
