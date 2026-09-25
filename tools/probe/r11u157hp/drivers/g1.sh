#!/bin/bash
# r11u157: one grid case. args: <case dir (absolute, holds dut.sv)> <out dir> [binary]
# golden: the pinned Surelog with check_probe's arguments, cached by the case text (sha1) under $GC;
# ours: $SLANG_UHDM (or arg 3) dut.sv --single-unit --nobuiltin; then strictcmp_x record dumps + the tool verdict.
set -u
c=$1; o=$2; bin=${3:-$SLANG_UHDM}; GC=${GC:-/tmp/r11u157_gcache}
mkdir -p "$o" "$GC"
h=$(cat "$c/dut.sv" | sha1sum | cut -c1-16)
g=$GC/$h.uhdm
if [ ! -s "$g" ]; then
  w=$(mktemp -d /tmp/r11u157_sl.XXXXXX)
  ( cd "$c" && timeout 300 "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w" > "$w/log" 2>&1 )
  f=$(find "$w" -name '*.uhdm' | head -1); [ -n "$f" ] && cp "$f" "$g"; rm -rf "$w"
fi
rm -f "$o/ours.uhdm"
( cd "$c" && timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$o/ours.uhdm" > "$o/slang.log" 2>&1; echo "rc=$?" >> "$o/slang.log" )
echo "$bin" > "$o/bin.txt"; echo "$g" > "$o/golden.txt"
[ -s "$g" ] || { echo NOGOLDEN > "$o/verdict"; exit 0; }
[ -s "$o/ours.uhdm" ] || { echo NOOURS > "$o/verdict"; exit 0; }
"$UHDM_CMP" "$g" "$o/ours.uhdm" > "$o/cmp.txt" 2>&1; echo "cmprc=$?" > "$o/verdict"
timeout 600 "$SCMP" --max 50 --dump-a "$o/g.a" --dump-b "$o/o.b" "$g" "$o/ours.uhdm" > "$o/strict.out" 2>&1; echo "strictrc=$?" >> "$o/verdict"
