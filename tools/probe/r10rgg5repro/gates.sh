#!/usr/bin/env bash
# r10rgg4/gates.sh — the five mandatory gate legs, one per subcommand.
#
#   usage: gates.sh {gold|goldneg|u2r|sl} [base|pat]
#
# Every leg writes to /tmp/r10rgg5_* and NEVER touches results/*.csv.
set -u
W=/tmp/wt_r10rgg5
BASEBIN=/tmp/r10rgg5_base_bin
PATBIN=/tmp/r10rgg5_pat_bin
which=${2:-pat}
case "$which" in
  base) BIN=$BASEBIN ;;
  pat)  BIN=$PATBIN ;;
  *)    BIN=$which ;;
esac
export SLANG_UHDM=$BIN
case "$1" in
  gold)
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/r10rgg5_gold_$which.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg5_gold_$which.txt) FAIL=$(grep -c '^FAIL' /tmp/r10rgg5_gold_$which.txt)"
    grep -v '^PASS' /tmp/r10rgg5_gold_$which.txt | head -20
    ;;
  goldneg)
    # NEGATIVE CONTROL: /bin/false as the exporter must PASS 0 and FAIL 23.
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/r10rgg5_goldneg.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rgg5_goldneg.txt) FAIL=$(grep -c '^FAIL' /tmp/r10rgg5_goldneg.txt)"
    ;;
  u2r)
    rm -rf /tmp/r10rgg5_u2rw_$which
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/r10rgg5_u2r_$which.csv --workdir /tmp/r10rgg5_u2rw_$which --jobs 2 \
      > /tmp/r10rgg5_u2r_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg5_u2r_$which.csv)"
    ;;
  sl)
    rm -rf /tmp/r10rgg5_slw_$which
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10rgg5_sl_$which.csv --workdir /tmp/r10rgg5_slw_$which --jobs 2 \
      > /tmp/r10rgg5_sl_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rgg5_sl_$which.csv)"
    ;;
esac
