#!/usr/bin/env bash
# r10vrgg11 gate legs.  MY OWN worktree + MY OWN out/workdirs; SLANG_UHDM
# exported EXPLICITLY per binary on every leg.
set -u
W=/tmp/wt_vrgg11pris
case "${2:?which}" in
  base) BIN=/tmp/vrgg11_bin/base_bin ;;
  pat)  BIN=/tmp/vrgg11_bin/pat_bin ;;
  fix)  BIN=/tmp/vrgg11_bin/fix_bin ;;
  *)    BIN=$2 ;;
esac
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
which=$2
export SLANG_UHDM=$BIN
case "$1" in
  gold)
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/vrgg11_gold_$which.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/vrgg11_gold_$which.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg11_gold_$which.txt; true)"
    ;;
  goldneg)
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/vrgg11_goldneg.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/vrgg11_goldneg.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg11_goldneg.txt; true)"
    ;;
  u2r)
    rm -rf /tmp/vrgg11_u2rw_$which
    SLANG_UHDM=$BIN python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/vrgg11_u2r_$which.csv --workdir /tmp/vrgg11_u2rw_$which --jobs 2 \
      > /tmp/vrgg11_u2r_$which.log 2>&1
    echo "rc=$? lines=$(wc -l < /tmp/vrgg11_u2r_$which.csv)"
    ;;
  sl)
    rm -rf /tmp/vrgg11_slw_$which
    SLANG_UHDM=$BIN python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/vrgg11_sl_$which.csv --workdir /tmp/vrgg11_slw_$which --jobs 2 \
      > /tmp/vrgg11_sl_$which.log 2>&1
    echo "rc=$? lines=$(wc -l < /tmp/vrgg11_sl_$which.csv)"
    ;;
esac
