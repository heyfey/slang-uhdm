#!/bin/bash
# r10bbp6: full gate — goldens, u2r testflags sweep, Surelog both-mode sweeps,
# each diffed against its committed baseline.  Usage: r10bbp6gate.sh <stage>
#   goldens | u2r | sl
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_71fd1d8a-85c-1
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
case "$1" in
  goldens)
    ./tests/check_goldens.sh > /tmp/r10bbp6_gold.txt 2>&1
    echo "GOLDEN_PASS $(grep -c '^PASS' /tmp/r10bbp6_gold.txt)"
    grep -v '^PASS' /tmp/r10bbp6_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10bbp6_u2rw
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --out /tmp/r10bbp6_u2r.csv --workdir /tmp/r10bbp6_u2rw --jobs 4 2>&1 | tail -8
    ;;
  sl)
    rm -rf /tmp/r10bbp6_slw
    python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10bbp6_sl.csv --workdir /tmp/r10bbp6_slw --jobs 4 2>&1 | tail -12
    ;;
esac
