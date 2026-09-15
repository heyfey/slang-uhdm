#!/bin/bash
# r11u34: run ONE arm file through Surelog (golden) and one slang-uhdm binary,
# dump both, and report rc for each side.  usage: arm.sh <file.sv> <outdir> [binary]
# Surelog gets the uhdm2rtlil reference line (-parse -nobuiltin -nocache -sv);
# slang-uhdm gets the harness's own translation of it (--single-unit).
set -u
F=$(readlink -f "${1:?file}"); OUT=${2:?outdir}; BIN=${3:-${SLANG_UHDM:?set SLANG_UHDM or pass the binary as $3}}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$OUT"; mkdir -p "$OUT/g" "$OUT/o"
( cd "$OUT/g" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); grc=$?
( cd "$OUT/o" && "$BIN" "$F" --single-unit -o slang.uhdm > our.log 2>&1 ); orc=$?
G=$(ls "$OUT"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
O=$OUT/o/slang.uhdm
echo "ARM $(basename "$F") slrc=$grc ourrc=$orc slerr=$(grep -c '\[ERROR\]' "$OUT/g/sl.log" 2>/dev/null; true)"
[ -n "$G" ] && "$DUMP" "$G" | sed "s#$OUT##g" > "$OUT/g.dump" 2>&1
[ -f "$O" ] && "$DUMP" "$O" | sed "s#$OUT##g" > "$OUT/o.dump" 2>&1
echo "  gdump=$( [ -s "$OUT/g.dump" ] && wc -l < "$OUT/g.dump" || echo NONE) odump=$( [ -s "$OUT/o.dump" ] && wc -l < "$OUT/o.dump" || echo NONE)"
