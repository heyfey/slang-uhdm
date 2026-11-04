#!/bin/bash
# away.sh <pristine> <law> <dir>: one census line: dir, rc and md5 of each binary's output (dut.sv --single-unit --nobuiltin)
P=$1; L=$2; d=$3
[ -x "$P" ] && [ -x "$L" ] && [ -d "$d" ] || exit 0
W=/tmp/r11u478_away$d; mkdir -p "$W"; rm -f "$W/p.uhdm" "$W/l.uhdm"
(cd "$d" && timeout 300 "$P" dut.sv --single-unit --nobuiltin -o "$W/p.uhdm" >/dev/null 2>&1 </dev/null); rp=$?
(cd "$d" && timeout 300 "$L" dut.sv --single-unit --nobuiltin -o "$W/l.uhdm" >/dev/null 2>&1 </dev/null); rl=$?
mp=$( [ -f "$W/p.uhdm" ] && md5sum < "$W/p.uhdm" | cut -c1-8 || echo none); ml=$( [ -f "$W/l.uhdm" ] && md5sum < "$W/l.uhdm" | cut -c1-8 || echo none)
echo "$d rcP=$rp rcL=$rl $mp $ml $( [ "$mp" = "$ml" ] && echo SAME || echo MOVED)"
