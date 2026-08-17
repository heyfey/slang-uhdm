#!/usr/bin/env bash
# r10rgg6/gates.sh — the mandatory gate legs, one per subcommand.
#
#   usage: gates.sh {gold|goldneg|u2r|sl} [base|pat|<binary path>]
#
# Every leg writes to /tmp/r10rgg6_* and NEVER touches results/*.csv.
# SLANG_UHDM is exported EXPLICITLY to the named binary on every leg, because
# BOTH verify_golden.py and tests/check_goldens.sh silently fall back to the
# MAIN-TREE build otherwise.
set -u
W=/tmp/wt_r10rgg6
BASEBIN=/tmp/r10rgg6_base_bin
PATBIN=/tmp/r10rgg6_pat_bin
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
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/r10rgg6_gold_$which.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg6_gold_$which.txt) FAIL=$(grep -c '^FAIL' /tmp/r10rgg6_gold_$which.txt)"
    grep -v '^PASS' /tmp/r10rgg6_gold_$which.txt | head -20
    ;;
  goldneg)
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/r10rgg6_goldneg.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg6_goldneg.txt) FAIL=$(grep -c '^FAIL' /tmp/r10rgg6_goldneg.txt)"
    ;;
  u2r)
    rm -rf /tmp/r10rgg6_u2rw_$which
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/r10rgg6_u2r_$which.csv --workdir /tmp/r10rgg6_u2rw_$which --jobs 2 \
      > /tmp/r10rgg6_u2r_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg6_u2r_$which.csv)"
    ;;
  sl)
    rm -rf /tmp/r10rgg6_slw_$which
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10rgg6_sl_$which.csv --workdir /tmp/r10rgg6_slw_$which --jobs 2 \
      > /tmp/r10rgg6_sl_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg6_sl_$which.csv)"
    ;;
esac
