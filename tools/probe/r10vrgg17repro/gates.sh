#!/usr/bin/env bash
# vrgg17 verifier gates — OWN pinned paths, SLANG_UHDM exported per binary.
set -u
W=/tmp/wt_vrgg17
BASEBIN=/tmp/vrgg17_bin/slang-uhdm-base
PATBIN=/tmp/vrgg17_bin/slang-uhdm-pat
which=${2:-pat}
case "$which" in base) BIN=$BASEBIN ;; pat) BIN=$PATBIN ;; *) BIN=$which ;; esac
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
export SLANG_UHDM=$BIN
case "$1" in
  gold)
    cd $W && SLANG_UHDM=$BIN ./tests/check_goldens.sh > /tmp/vrgg17_gold_$which.txt 2>&1
    echo "gold[$which] PASS=$(grep -c '^PASS' /tmp/vrgg17_gold_$which.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg17_gold_$which.txt; true)" ;;
  goldneg)
    cd $W && SLANG_UHDM=/bin/false ./tests/check_goldens.sh > /tmp/vrgg17_goldneg.txt 2>&1
    echo "goldneg PASS=$(grep -c '^PASS' /tmp/vrgg17_goldneg.txt; true) FAIL=$(grep -c '^FAIL' /tmp/vrgg17_goldneg.txt; true)" ;;
  u2r)
    rm -rf /tmp/vrgg17_u2rw_$which
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode both \
      --out /tmp/vrgg17_u2r_$which.csv --workdir /tmp/vrgg17_u2rw_$which --jobs 2 \
      > /tmp/vrgg17_u2r_$which.log 2>&1
    echo "u2r[$which] lines=$(wc -l < /tmp/vrgg17_u2r_$which.csv)" ;;
  sl)
    rm -rf /tmp/vrgg17_slw_$which
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/vrgg17_sl_$which.csv --workdir /tmp/vrgg17_slw_$which --jobs 2 \
      > /tmp/vrgg17_sl_$which.log 2>&1
    echo "sl[$which] lines=$(wc -l < /tmp/vrgg17_sl_$which.csv)" ;;
esac
