#!/usr/bin/env bash
# The regression gate: (1) every tests/probe arm judged EQUAL against its cached
# golden (scripts/check_probe.py); (2) both corpora in both modes with
# scripts/verify_golden.py compared against the committed scoreboards in results/;
# (3) the downstream gate: uhdm2rtlil's Yosys plugin must produce the same
# result from slang-uhdm's database as from Surelog's on every uhdm2rtlil test
# except the slang-rejected ones (scripts/downstream_uhdm2rtlil.py, verdicts
# compared against results/downstream_uhdm2rtlil.csv).
#
#   tests/sweep.sh [--jobs N] [--workdir DIR] [--filter REGEX] [--corpus probe|surelog|uhdm2rtlil|downstream]
#
# First run on a machine: Surelog builds every golden database (about an hour
# at --jobs 3) and the harness caches them under ~/.cache/slang-uhdm-goldens
# (GOLDEN_CACHE=<dir> relocates). Every later run is served from the cache and
# takes a few minutes per corpus. Tool and corpus locations resolve relative to
# this repository (third_party/Surelog, third_party/uhdm2rtlil, build/); the
# variables SURELOG, UHDM_CMP, UHDM_DUMP, SLANG_UHDM, SURELOG_ROOT and
# UHDM2RTLIL_TESTS override them. Exit status 1 on any probe arm not EQUAL or any
# corpus status regression: do not commit on a nonzero exit.
set -u
ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
JOBS=3; WORKDIR=/tmp/slang-uhdm-sweep; FILTER=""; CORPORA="probe surelog uhdm2rtlil downstream"
while [ $# -gt 0 ]; do
    case "$1" in
        --jobs) JOBS=$2; shift 2 ;;
        --workdir) WORKDIR=$2; shift 2 ;;
        --filter) FILTER=$2; shift 2 ;;
        --corpus) CORPORA=$2; shift 2 ;;
        *) echo "usage: $0 [--jobs N] [--workdir DIR] [--filter REGEX] [--corpus probe|surelog|uhdm2rtlil|downstream]"; exit 2 ;;
    esac
done
mkdir -p "$WORKDIR"
rc=0
# The law index (tests/LAWS.csv + tests/LAWS.md) must be regenerated with
# every landing that adds or renames a law, an arm or a pass README.
python3 "$ROOT/scripts/law_index.py" --check || rc=1
for c in $CORPORA; do
    if [ "$c" = probe ]; then
        echo "== probe arms (tests/probe, committed goldens), jobs=$JOBS"
        python3 "$ROOT/scripts/check_probe.py" --jobs "$JOBS" --workdir "$WORKDIR/probe" ${FILTER:+--filter "$FILTER"} || rc=1
        continue
    fi
    if [ "$c" = downstream ]; then
        echo "== downstream: uhdm2rtlil (Yosys plugin) on slang-uhdm's vs Surelog's databases, jobs=$JOBS"
        python3 "$ROOT/scripts/downstream_uhdm2rtlil.py" --jobs "$JOBS" --workdir "$WORKDIR/downstream" \
            --out "$WORKDIR/downstream.csv" --baseline "$ROOT/results/downstream_uhdm2rtlil.csv" \
            ${FILTER:+--filter "$FILTER"} || rc=1
        continue
    fi
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
