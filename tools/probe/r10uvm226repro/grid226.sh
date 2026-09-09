#!/bin/bash
# § ifaceDefListsItsOwnProcesses226 — the GOLDEN GRID driver.
#
# Compiles every arm SUBDIRECTORY under grid226/ with the CANONICAL golden-side
# Surelog (the one scripts/verify_golden.py names) and with the slang-uhdm
# binary the caller pins in $SLANG_UHDM, dumps both databases, and records
# EVERY arm's return code on BOTH sides.  A non-zero rc is printed loudly: an
# arm whose compile FAILS teaches error recovery, not golden (uvm215's lesson).
#
#   usage: SLANG_UHDM=<binary> bash grid226.sh <outdir> [armdir]
set -u
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
OUT=${1:?outdir}
ARMS=${2:-$(cd "$(dirname "$0")" && pwd)/grid226}
BIN=${SLANG_UHDM:?export SLANG_UHDM}
mkdir -p "$OUT"
echo "grid226: surelog=$SL"
echo "grid226: slang  =$BIN  md5=$(md5sum "$BIN" | cut -c1-12)"
listed=0; processed=0
for f in "$ARMS"/*/dut.sv; do
    listed=$((listed+1))
done
for f in "$ARMS"/*/dut.sv; do
    n=$(basename "$(dirname "$f")")
    d="$OUT/$n"
    mkdir -p "$d/g" "$d/o"
    ( cd "$d/g" && "$SL" -parse -nobuiltin -nocache -sv "$f" > sl.log 2>&1 </dev/null )
    grc=$?
    ( cd "$d/o" && "$BIN" "$f" -o slang.uhdm > o.log 2>&1 </dev/null )
    orc=$?
    gdb=$(ls "$d/g"/slpp_all/surelog.uhdm 2>/dev/null | head -1)
    odb=$(ls "$d/o"/slang.uhdm 2>/dev/null | head -1)
    [ -n "$gdb" ] && "$DUMP" "$gdb" > "$d/golden.dump" 2>/dev/null
    [ -n "$odb" ] && "$DUMP" "$odb" > "$d/ours.dump" 2>/dev/null
    gl=$( [ -f "$d/golden.dump" ] && wc -l < "$d/golden.dump" || echo 0 )
    ol=$( [ -f "$d/ours.dump" ]   && wc -l < "$d/ours.dump"   || echo 0 )
    echo "ARM $n  surelog_rc=$grc golden_lines=$gl   slang_rc=$orc ours_lines=$ol"
    if [ "$grc" != 0 ] || [ "$orc" != 0 ]; then
        echo "  !! NONZERO RC — this arm teaches ERROR RECOVERY, not golden"
    fi
    processed=$((processed+1))
done
echo "grid226: LISTED $listed PROCESSED $processed"
[ "$listed" = "$processed" ] || echo "  !! LISTED != PROCESSED"
