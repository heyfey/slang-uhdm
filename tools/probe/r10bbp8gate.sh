#!/bin/bash
# r10bbp8gate: goldens / u2r testflags / Surelog both-mode sweeps + a csv
# comparison against the committed baselines.  Set W to the worktree root.
#   usage: r10bbp8gate.sh goldens|u2r|sl
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
  goldens)
    ./tests/check_goldens.sh > /tmp/r10bbp8_gold.txt 2>&1
    echo "GOLDEN_PASS $(grep -c '^PASS' /tmp/r10bbp8_gold.txt)"
    grep -v '^PASS' /tmp/r10bbp8_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10bbp8_u2rw
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --out /tmp/r10bbp8_u2r.csv --workdir /tmp/r10bbp8_u2rw --jobs 4 2>&1 | tail -8
    cmp_csv results/gate_uhdm2rtlil.csv /tmp/r10bbp8_u2r.csv
    ;;
  sl)
    rm -rf /tmp/r10bbp8_slw
    python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10bbp8_sl.csv --workdir /tmp/r10bbp8_slw --jobs 4 2>&1 | tail -12
    cmp_csv results/golden_surelog.csv /tmp/r10bbp8_sl.csv
    ;;
esac
