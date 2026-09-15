#!/bin/bash
# r11u39 arm runner: surelog golden + our binary, both dumped, per arm dir.
# Records rc for BOTH producers -- an arm whose compile FAILS teaches
# error-recovery, not golden.
set -u
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
BIN=${BIN:?BIN=<slang-uhdm binary>}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
A=${1:?arm dir}
TAG=${2:-out}
cd "$A" || exit 3
rm -rf slpp_all slpp_unit "$TAG.uhdm"
"$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$A/sl_$TAG" > "$A/sl_$TAG.log" 2>&1
echo "surelog rc=$?"
G=$(ls "$A/sl_$TAG"/slpp_all/*.uhdm "$A/sl_$TAG"/slpp_unit/*.uhdm 2>/dev/null | head -1)
echo "golden=$G"
"$BIN" dut.sv --single-unit -o "$A/$TAG.uhdm" > "$A/ours_$TAG.log" 2>&1
echo "slang rc=$?"
[ -n "$G" ] && [ -f "$G" ] && "$DUMP" "$G" > "$A/g_$TAG.dump" 2>&1; echo "gdump rc=$?"
[ -f "$A/$TAG.uhdm" ] && "$DUMP" "$A/$TAG.uhdm" > "$A/o_$TAG.dump" 2>&1; echo "odump rc=$?"
if [ -n "$G" ] && [ -f "$G" ] && [ -f "$A/$TAG.uhdm" ]; then
  "$HOME/.local/bin/uhdm-cmp" "$G" "$A/$TAG.uhdm" > "$A/cmp_$TAG.txt" 2>&1
  echo "cmp rc=$? lines=$(wc -l < "$A/cmp_$TAG.txt") heads=$(grep -c '^LHS:' "$A/cmp_$TAG.txt"; true)"
fi
