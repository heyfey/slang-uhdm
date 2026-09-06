#!/usr/bin/env bash
# r10uvm176repro/wface176.sh — THE LAW'S FACE, counted over a WHOLE
# verify_golden workdir, BOTH SIDES, and joined.  MEASUREMENT ONLY.
#
#   wface176.sh <workdir> <ct176cen> <out-prefix>
#
# The FACE is every argument reference of a `method_func_call`/`method_task_call`
# that carries a vpiPrefix and NO vpiFunction/vpiTask link — the shape
# `CompileHelper::compileTfCall`'s dotted arm builds and the shape this law's
# arm emits.  Running the FULL families over 956 databases would be ~40M rows;
# the face is a few hundred per database.
#
# Prints the FACEDIFF count (cells whose bind-state multiset differs between
# golden and ours) and, when a SECOND workdir is given, the movers BY NAME with
# the TOGOLD / AWAY / MOVED-WRONG columns.
set -u
WD=${1:?workdir}; CEN=${2:?ct176cen}; OUT=${3:?out-prefix}
WD2=${4:-}
CENFLAGS=--face bash "$(dirname "$0")/cen176.sh" "$WD" "$CEN" "$OUT.pris.txt"
if [ -n "$WD2" ]; then
  CENFLAGS=--face bash "$(dirname "$0")/cen176.sh" "$WD2" "$CEN" "$OUT.pat.txt"
fi
python3 - "$OUT.pris.txt" "${WD2:+$OUT.pat.txt}" <<'PY'
import sys
from collections import Counter, defaultdict


def load(p):
    G, O = defaultdict(Counter), defaultdict(Counter)
    for line in open(p, encoding="utf-8", errors="replace"):
        q = line.rstrip("\n").split("|")
        if len(q) < 4 or q[0] != "ARG":
            continue
        (G if q[1] == "G" else O)["|".join(q[2:-1])][q[-1]] += 1
    return G, O


g, a = load(sys.argv[1])
wrongA = {k for k in set(g) | set(a) if g.get(k) != a.get(k)}
print(f"FACE cells (golden) = {len(g)}   FACEDIFF (pristine) = {len(wrongA)}")
if len(sys.argv) > 2 and sys.argv[2]:
    g2, b = load(sys.argv[2])
    print("golden face rows identical across the two runs:", g == g2)
    wrongB = {k for k in set(g) | set(b) if g.get(k) != b.get(k)}
    moved = {k for k in set(a) | set(b) if a.get(k) != b.get(k)}
    mw = {k for k in (wrongA & wrongB) if a.get(k) != b.get(k)}
    print(f"FACEDIFF {len(wrongA)} -> {len(wrongB)}   MOVED={len(moved)} "
          f"TOGOLD={len(wrongA - wrongB)} AWAY={len(wrongB - wrongA)} "
          f"MOVEDWRONG={len(mw)}")
    for k in sorted(moved):
        print("   MOVER", k)
        print("      G=", dict(g.get(k, {})), " A=", dict(a.get(k, {})),
              " B=", dict(b.get(k, {})))
PY
