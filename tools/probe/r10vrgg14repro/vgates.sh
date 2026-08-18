#!/usr/bin/env bash
# r10rgg14/gates14.sh — the mandatory gate legs, one per subcommand.
#   usage: gates14.sh {gold|goldneg|u2r|sl} [base|pat|<binary path>]
# Every leg writes to /tmp/vrgg14_g_* and NEVER touches results/*.csv.
# SLANG_UHDM is exported EXPLICITLY to the named binary on every leg, because
# BOTH verify_golden.py and tests/check_goldens.sh silently fall back to the
# MAIN-TREE build otherwise.
set -u
W=/tmp/wt_vrgg14
BASEBIN=/tmp/vrgg14_bin/slang-uhdm-BASE
PATBIN=/tmp/vrgg14_bin/slang-uhdm-VFIX
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
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/vrgg14_g_gold_$which.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/vrgg14_g_gold_$which.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg14_g_gold_$which.txt; true)"
    grep -v '^PASS' /tmp/vrgg14_g_gold_$which.txt | head -20
    ;;
  goldneg)
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/vrgg14_g_goldneg.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/vrgg14_g_goldneg.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg14_g_goldneg.txt; true)"
    ;;
  u2r)
    rm -rf /tmp/vrgg14_g_u2rw_$which
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/vrgg14_g_u2r_$which.csv --workdir /tmp/vrgg14_g_u2rw_$which --jobs 2 \
      > /tmp/vrgg14_g_u2r_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/vrgg14_g_u2r_$which.csv)"
    ;;
  sl)
    rm -rf /tmp/vrgg14_g_slw_$which
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/vrgg14_g_sl_$which.csv --workdir /tmp/vrgg14_g_slw_$which --jobs 2 \
      > /tmp/vrgg14_g_sl_$which.log 2>&1
    echo "lines=$(wc -l < /tmp/vrgg14_g_sl_$which.csv)"
    ;;
esac
