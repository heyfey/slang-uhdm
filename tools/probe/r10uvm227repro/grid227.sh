#!/bin/bash
# § pkgFreeCallTakesFirstListingImport227 — the GOLDEN GRID driver.
# MEASUREMENT ONLY; the official `uhdm-cmp` remains the sole acceptance judge.
#
# Compiles every arm SUBDIRECTORY under grid227/ with the CANONICAL golden-side
# Surelog (the one `scripts/verify_golden.py` names) and with the slang-uhdm
# binary the caller pins in $SLANG_UHDM, dumps both databases, runs
# `ct227route` on each, and records EVERY arm's return code on BOTH sides.  A
# non-zero rc is printed LOUDLY: an arm whose compile FAILS teaches error
# recovery, not golden (uvm215's lesson).  LISTED is asserted against PROCESSED
# (a top-level glob that runs nothing must never read as green), the arm list is
# read on fd 3 and children get </dev/null, and each arm's scratch is keyed on
# the arm's RELATIVE path.
#
#   usage: SLANG_UHDM=<binary> bash grid227.sh <outdir> [armdir] [name]
set -u
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
ROUTE=${ROUTE:-/tmp/r10uvm227_ct227route}
OUT=${1:?outdir}
ARMS=${2:-$(cd "$(dirname "$0")" && pwd)/grid227}
NAME=${3:-f}
BIN=${SLANG_UHDM:?export SLANG_UHDM}
mkdir -p "$OUT"
echo "grid227: surelog=$SL"
echo "grid227: slang  =$BIN  md5=$(md5sum "$BIN" | cut -c1-12)"
echo "grid227: route  =$ROUTE"
listed=0
: > "$OUT/.arms"
for f in "$ARMS"/*/dut.sv; do
    [ -f "$f" ] || continue
    echo "$f" >> "$OUT/.arms"
    listed=$((listed+1))
done
processed=0
while read -r f <&3; do
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
    [ -n "$gdb" ] && "$ROUTE" "$gdb" "$NAME" > "$d/golden.route" 2>&1
    [ -n "$odb" ] && "$ROUTE" "$odb" "$NAME" > "$d/ours.route" 2>&1
    gl=$( [ -f "$d/golden.dump" ] && wc -l < "$d/golden.dump" || echo 0 )
    ol=$( [ -f "$d/ours.dump" ]   && wc -l < "$d/ours.dump"   || echo 0 )
    echo "ARM $n  surelog_rc=$grc golden_lines=$gl   slang_rc=$orc ours_lines=$ol"
    if [ "$grc" != 0 ] || [ "$orc" != 0 ]; then
        echo "  !! NONZERO RC — this arm teaches ERROR RECOVERY, not golden"
    fi
    processed=$((processed+1))
done 3< "$OUT/.arms"
echo "grid227: LISTED $listed PROCESSED $processed"
[ "$listed" = "$processed" ] && echo "grid227: LISTED == PROCESSED" || echo "  !! LISTED != PROCESSED"
