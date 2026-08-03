#!/bin/bash
# r10bbp7: full gate — goldens, u2r testflags sweep, Surelog both-mode sweeps.
#   Usage: r10bbp7gate.sh goldens | u2r | sl
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_512b5480-e53-1
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
case "$1" in
  goldens)
    ./tests/check_goldens.sh > /tmp/r10bbp7_gold.txt 2>&1
    echo "GOLDEN_PASS $(grep -c '^PASS' /tmp/r10bbp7_gold.txt)"
    grep -v '^PASS' /tmp/r10bbp7_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10bbp7_u2rw
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --out /tmp/r10bbp7_u2r.csv --workdir /tmp/r10bbp7_u2rw --jobs 4 2>&1 | tail -8
    ;;
  sl)
    rm -rf /tmp/r10bbp7_slw
    python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10bbp7_sl.csv --workdir /tmp/r10bbp7_slw --jobs 4 2>&1 | tail -12
    ;;
esac
