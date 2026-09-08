#!/bin/bash
# § ifaceOwnCallCalleeFormRoutes222 — the GOLDEN GRID driver.
#
# Compiles every arm under grid222/ with the CANONICAL golden-side Surelog
# (the one scripts/verify_golden.py names) and with the slang-uhdm binary the
# caller pins in $SLANG_UHDM, dumps both databases, and records EVERY arm's
# return code on both sides.  An arm whose compile FAILS teaches error
# recovery, not golden (uvm215's lesson), so the rc is part of the record and
# a non-zero one is printed loudly rather than silently folded into "agrees".
#
#   usage: SLANG_UHDM=<binary> bash grid222.sh <outdir> [armdir]
set -u
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
OUT=${1:?outdir}
ARMS=${2:-$(cd "$(dirname "$0")" && pwd)/grid222}
BIN=${SLANG_UHDM:?export SLANG_UHDM}
mkdir -p "$OUT"
echo "grid222: surelog=$SL"
echo "grid222: slang  =$BIN  md5=$(md5sum "$BIN" | cut -c1-12)"
for f in "$ARMS"/*.sv; do
    n=$(basename "$f" .sv)
    d="$OUT/$n"
    mkdir -p "$d/g" "$d/o"
    ( cd "$d/g" && "$SL" -parse -nobuiltin -nocache -sv "$f" > sl.log 2>&1 )
    grc=$?
    ( cd "$d/o" && "$BIN" "$f" -o slang.uhdm > o.log 2>&1 )
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
done
