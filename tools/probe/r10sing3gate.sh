#!/bin/bash
# r10sing3gate: goldens / u2r testflags / Surelog both-mode sweeps + a csv
# comparison against the committed baselines.  Compares BOTH status AND the
# dump column (a dump=match -> '' demotion is a regression even when the
# status column is unchanged -- the LowMemPkg lesson).
#   usage: r10sing3gate.sh goldens|u2r|sl
W=${W:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_f76a1f6c-481-1}
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
cmp_csv() { python3 - "$1" "$2" <<'PY'
import csv, sys
def load(p):
    return {(r['name'], r['mode']): (r['status'], r.get('dump', ''))
            for r in csv.DictReader(open(p))}
base, new = load(sys.argv[1]), load(sys.argv[2])
ch = [(k, base.get(k), v) for k, v in new.items() if base.get(k) != v]
print("rows base=%d new=%d changed=%d" % (len(base), len(new), len(ch)))
for k, b, n in sorted(ch):
    print(k, b, "->", n)
missing = [k for k in base if k not in new]
if missing:
    print("MISSING FROM NEW:", len(missing), sorted(missing)[:10])
from collections import Counter
print("new tallies:", sorted(Counter((k[1], v[0]) for k, v in new.items()).items()))
PY
}
case "$1" in
  goldens)
    ./tests/check_goldens.sh > /tmp/r10sing3_gold.txt 2>&1
    echo "GOLDEN_PASS $(grep -c '^PASS' /tmp/r10sing3_gold.txt)"
    grep -v '^PASS' /tmp/r10sing3_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10sing3_u2rw
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --out /tmp/r10sing3_u2r.csv --workdir /tmp/r10sing3_u2rw --jobs 4 2>&1 | tail -8
    cmp_csv results/gate_uhdm2rtlil.csv /tmp/r10sing3_u2r.csv
    ;;
  sl)
    rm -rf /tmp/r10sing3_slw
    python3 scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10sing3_sl.csv --workdir /tmp/r10sing3_slw --jobs 4 2>&1 | tail -12
    cmp_csv results/golden_surelog.csv /tmp/r10sing3_sl.csv
    ;;
esac
