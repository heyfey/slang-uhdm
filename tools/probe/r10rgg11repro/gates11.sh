#!/usr/bin/env bash
# r10rgg11/gates11.sh — the mandatory gate legs, one per subcommand.
#
#   usage: gates11.sh {gold|goldneg|u2r|sl} [base|pat|<binary path>]
#
# Every leg writes to /tmp/r10rgg11_* and NEVER touches results/*.csv.
# SLANG_UHDM is exported EXPLICITLY to the named binary on every leg, because
# BOTH verify_golden.py and tests/check_goldens.sh silently fall back to the
# MAIN-TREE build otherwise.
set -u
W=/tmp/wt_r10rgg11
BASEBIN=/tmp/r10rgg11_base_bin
PATBIN=/tmp/r10rgg11_pat_bin
which=${2:-pat}
case "$which" in
  base) BIN=$BASEBIN ;;
  pat)  BIN=$PATBIN ;;
  *)    BIN=$which ;;
esac
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
export SLANG_UHDM=$BIN
case "$1" in
  gold)
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/r10rgg11_gold_$which.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg11_gold_$which.txt; true) FAIL=$(grep -c '^FAIL' /tmp/r10rgg11_gold_$which.txt; true)"
    grep -v '^PASS' /tmp/r10rgg11_gold_$which.txt | head -20
    ;;
  goldneg)
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/r10rgg11_goldneg.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg11_goldneg.txt; true) FAIL=$(grep -c '^FAIL' /tmp/r10rgg11_goldneg.txt; true)"
    ;;
  u2r)
    rm -rf /tmp/r10rgg11_u2rw_$which
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/r10rgg11_u2r_$which.csv --workdir /tmp/r10rgg11_u2rw_$which --jobs 2 \
      > /tmp/r10rgg11_u2r_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg11_u2r_$which.csv)"
    ;;
  sl)
    rm -rf /tmp/r10rgg11_slw_$which
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10rgg11_sl_$which.csv --workdir /tmp/r10rgg11_slw_$which --jobs 2 \
      > /tmp/r10rgg11_sl_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg11_sl_$which.csv)"
    ;;
esac
