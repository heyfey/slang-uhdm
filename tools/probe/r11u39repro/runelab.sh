#!/bin/bash
# r11u39 arm runner, ELAB VIEW (-elabuhdm / --elabuhdm on both producers).
set -u
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
BIN=${BIN:?BIN=<slang-uhdm binary>}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
A=${1:?arm dir}; TAG=${2:-elab}
cd "$A" || exit 3
"$SL" -parse -elabuhdm -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$A/sl_$TAG" > "$A/sl_$TAG.log" 2>&1
echo "surelog rc=$?"
G=$(ls "$A/sl_$TAG"/slpp_all/*.uhdm "$A/sl_$TAG"/slpp_unit/*.uhdm 2>/dev/null | head -1)
echo "golden=$G"
"$BIN" dut.sv --single-unit --elabuhdm -o "$A/$TAG.uhdm" > "$A/ours_$TAG.log" 2>&1
echo "slang rc=$?"
[ -n "$G" ] && [ -f "$G" ] && "$DUMP" "$G" > "$A/g_$TAG.dump" 2>&1
[ -f "$A/$TAG.uhdm" ] && "$DUMP" "$A/$TAG.uhdm" > "$A/o_$TAG.dump" 2>&1
echo "dumps done"
