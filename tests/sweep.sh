#!/usr/bin/env bash
# The regression gate: run both corpora in both modes with scripts/verify_golden.py
# and compare every row's status against the committed scoreboards in results/.
#
#   tests/sweep.sh [--jobs N] [--workdir DIR] [--filter REGEX] [--corpus surelog|uhdm2rtlil]
#
# First run on a machine: Surelog builds every golden database (about an hour
# at --jobs 3) and the harness caches them under ~/.cache/slang-uhdm-goldens
# (GOLDEN_CACHE=<dir> relocates). Every later run is served from the cache and
# takes a few minutes per corpus. Tool and corpus locations resolve relative to
# this repository (third_party/Surelog, third_party/uhdm2rtlil, build/); the
# variables SURELOG, UHDM_CMP, UHDM_DUMP, SLANG_UHDM, SURELOG_ROOT and
# UHDM2RTLIL_TESTS override them. Exit status 1 on any status regression.
set -u
ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
JOBS=3; WORKDIR=/tmp/slang-uhdm-sweep; FILTER=""; CORPORA="surelog uhdm2rtlil"
while [ $# -gt 0 ]; do
    case "$1" in
        --jobs) JOBS=$2; shift 2 ;;
        --workdir) WORKDIR=$2; shift 2 ;;
        --filter) FILTER=$2; shift 2 ;;
        --corpus) CORPORA=$2; shift 2 ;;
        *) echo "usage: $0 [--jobs N] [--workdir DIR] [--filter REGEX] [--corpus surelog|uhdm2rtlil]"; exit 2 ;;
    esac
done
mkdir -p "$WORKDIR"
rc=0
for c in $CORPORA; do
    out=$WORKDIR/$c.csv
    echo "== $c: both modes, jobs=$JOBS, out=$out"
    python3 "$ROOT/scripts/verify_golden.py" --corpus "$c" --mode both --jobs "$JOBS" \
        --out "$out" --workdir "$WORKDIR/$c" ${FILTER:+--filter "$FILTER"} || { rc=1; continue; }
    case $c in
        surelog) base=$ROOT/results/golden_surelog.csv ;;
        uhdm2rtlil) base=$ROOT/results/golden_uhdm2rtlil.csv ;;
    esac
    echo "== $c vs $(basename "$base")"
    python3 "$ROOT/scripts/compare_results.py" "$out" "$base" || rc=1
done
hits=$(grep -rl 'golden cache hit' "$WORKDIR" --include=cmds.txt 2>/dev/null | wc -l)
total=$(find "$WORKDIR" -name cmds.txt | wc -l)
echo "golden cache: $hits of $total runs served from the cache"
exit $rc
