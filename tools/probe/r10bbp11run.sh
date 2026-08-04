#!/bin/bash
# r10bbp11run: single-test verify_golden runs for the BlackBePipeInt pass-11
# work, plus the three gate sweeps.  Set W to the worktree root.
#   usage: r10bbp11run.sh one <mode> <tag>   # one surelog test, both dumps kept
#          r10bbp11run.sh goldens|u2r|sl
W=${W:-$PWD}
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
cmp_csv() { python3 - "$1" "$2" <<'PY'
import csv, sys
def load(p):
    return {(r['name'], r['mode']): r['status'] for r in csv.DictReader(open(p))}
base, new = load(sys.argv[1]), load(sys.argv[2])
ch = [(k, base.get(k), v) for k, v in new.items() if base.get(k) != v]
print("rows base=%d new=%d changed=%d" % (len(base), len(new), len(ch)))
for k, b, n in sorted(ch):
    print(k, b, "->", n)
PY
}
case "$1" in
  one)
    M=${2:-default}; T=${3:-r10bbp11a}
    rm -rf /tmp/${T}_w
    timeout 1800 python3 scripts/verify_golden.py --corpus surelog --mode "$M" \
      --filter '^BlackBePipeInt$' --out /tmp/${T}.csv --workdir /tmp/${T}_w \
      --jobs 1 2>&1 | tail -20
    cat /tmp/${T}.csv
    ;;
  goldens)
    ./tests/check_goldens.sh > /tmp/r10bbp11_gold.txt 2>&1
    echo "GOLDEN_PASS $(grep -c '^PASS' /tmp/r10bbp11_gold.txt)"
    grep -v '^PASS' /tmp/r10bbp11_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10bbp11_u2rw
    timeout 3000 python3 scripts/verify_golden.py --corpus uhdm2rtlil \
      --mode testflags --out /tmp/r10bbp11_u2r.csv \
      --workdir /tmp/r10bbp11_u2rw --jobs 4 2>&1 | tail -8
    cmp_csv results/gate_uhdm2rtlil.csv /tmp/r10bbp11_u2r.csv
    ;;
  sl)
    rm -rf /tmp/r10bbp11_slw
    timeout 9000 python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10bbp11_sl.csv --workdir /tmp/r10bbp11_slw --jobs 4 2>&1 | tail -12
    cmp_csv results/golden_surelog.csv /tmp/r10bbp11_sl.csv
    ;;
esac
