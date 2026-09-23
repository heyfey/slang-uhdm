#!/usr/bin/env bash
# converge.sh <dut.sv> [extra slang-uhdm args...]
# Runs Surelog and slang-uhdm on the same source, diffs uhdm-dump output and
# runs uhdm-cmp. Prints DUMP_MATCH/DUMP_DIFF and PASS_CMP/CMP_FAIL.
set -u

ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
SURELOG_ROOT=${SURELOG_ROOT:-$ROOT/third_party/Surelog}
UHDM_BIN=$SURELOG_ROOT/build/third_party/UHDM/bin
SLANG_UHDM=${SLANG_UHDM:-$ROOT/build/slang-uhdm}
SURELOG=${SURELOG:-$SURELOG_ROOT/build/bin/surelog}
UHDM_DUMP=${UHDM_DUMP:-$UHDM_BIN/uhdm-dump}
UHDM_CMP=${UHDM_CMP:-$UHDM_BIN/uhdm-cmp}

SRC=$(realpath "$1")
shift
WORK=${WORK:-$(mktemp -d /tmp/uhdm-converge.XXXXXX)}
mkdir -p "$WORK"
cd "$WORK" || exit 9

# Reference producer.
# Policy (GOLDEN_EQUIVALENCE.md §5 2b, decided: match Surelog): the golden is
# the ARTIFACT, not the exit code. Surelog can report compile errors (rc=4)
# and still write a complete database, and its own regression suite records
# those errors in the golden logs — i.e. upstream treats the output as the
# expected result. Only a missing database is a Surelog failure.
"$SURELOG" -parse -nobuiltin -nocache "$SRC" >surelog.log 2>&1
SURELOG_EXIT=$?
SUHDM=$WORK/slpp_all/surelog.uhdm
if [ ! -f "$SUHDM" ]; then
    echo "SURELOG_FAIL exit=$SURELOG_EXIT ($WORK/surelog.log)"
    exit 5
fi
[ $SURELOG_EXIT -ne 0 ] && echo "SURELOG_RC=$SURELOG_EXIT (db written; compared anyway)"

# Our producer
# Surelog is invoked with -nobuiltin below, so slang-uhdm must match it:
# builtins are ON by default on both sides now.
"$SLANG_UHDM" "$SRC" --nobuiltin -o slang.uhdm "$@" >slang.log 2>&1
SLANG_EXIT=$?
if [ $SLANG_EXIT -eq 4 ]; then
    echo "UNSUPPORTED:"
    sed -n '/unsupported constructs/,$p' slang.log | tail -n +2
elif [ $SLANG_EXIT -ne 0 ]; then
    echo "SLANG_FAIL exit=$SLANG_EXIT ($WORK/slang.log)"
    exit 6
fi
[ -f slang.uhdm ] || { echo "SLANG_NO_UHDM"; exit 6; }

# Dump both; normalize: drop banner line naming the file
"$UHDM_DUMP" "$SUHDM" 2>/dev/null | sed '1d' >surelog.dump
"$UHDM_DUMP" slang.uhdm 2>/dev/null | sed '1d' >slang.dump

if diff -u surelog.dump slang.dump >dump.diff; then
    echo "DUMP_MATCH"
else
    echo "DUMP_DIFF $(grep -c '^[-+]' dump.diff) lines ($WORK/dump.diff)"
fi

if "$UHDM_CMP" "$SUHDM" slang.uhdm >cmp.log 2>&1; then
    echo "PASS_CMP"
else
    echo "CMP_FAIL ($WORK/cmp.log)"
fi
echo "workdir: $WORK"
