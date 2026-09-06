#!/usr/bin/env bash
# r10uvm179repro/predict179.sh — THE A-PRIORI MOVER PREDICTION, from the
# PRISTINE databases alone.  MEASUREMENT ONLY.  Run this BEFORE the patched
# sweep: a mover the pass did not name here is a mover the pass did not
# understand (RESUME.md §7).
#
#   predict179.sh <pristine face census> [<second face census> ...]
#
# Descended from r10uvm176repro/predict176.sh; the DIRECTION is INVERTED
# because this law's is.  r10uvm176 ADDED a `vpiActual` that was absent, so its
# candidates were "ours BARE, golden BINDS".  This law SUPPRESSES a `vpiActual`
# that is present, so the candidate set is:
#
#   * the cell is in THIS pass's FACE — an argument of a `method_func_call` /
#     `method_task_call` that is an ELEMENT OF A `hier_path`, i.e. the road
#     `CompileHelper::compileComplexFuncCall` (CompileExpression.cpp:5678-5708)
#     builds for an EXPRESSION-position call on a hierarchical receiver;
#   * OUR side binds it to a `ref_var` — the ONLY value this law can move,
#     because `refVarLocalNoBind5` fires on nothing else;
#   * its HOME container is a PACKAGE — the def-package clone of an
#     out-of-body class method, which is what `pkgDefViewBody9` names.
#
# It also splits the candidates by CALLEE, because the counter the window reads
# (`recvUserMethodArgDepth107`) is raised at the USER-method arm only: a
# BUILT-IN method call on the same road is a different emitter arm and is
# predicted NOT to move (this pass's residue R1).
set -u
python3 - "$@" <<'PY'
import sys
from collections import Counter, defaultdict


def load(p):
    G, O = defaultdict(Counter), defaultdict(Counter)
    rowsG, rowsO = [], []
    for line in open(p, encoding="utf-8", errors="replace"):
        q = line.rstrip("\n").split("|")
        if len(q) < 4 or q[0] != "ARG":
            continue
        key = "|".join(q[2:-1])
        if q[1] == "G":
            G[key][q[-1]] += 1
            rowsG.append((key, q[-1]))
        else:
            O[key][q[-1]] += 1
            rowsO.append((key, q[-1]))
    return G, O, rowsG, rowsO


def field(k, name):
    for f in k.split("|"):
        if f.startswith(name + "="):
            return f[len(name) + 1:]
    return ""


BUILTIN = {"exists", "size", "num", "push_back", "push_front", "delete",
           "first", "next", "last", "prev", "pop_back", "pop_front",
           "insert", "find", "sum", "product", "min", "max", "unique"}

for p in sys.argv[1:]:
    if not p:
        continue
    g, o, rg, ro = load(p)
    print(p)
    print(f"  face rows: golden {len(rg)}  ours {len(ro)}")
    cand = [(k, v) for (k, v) in ro
            if v.startswith("BOUND=ref_var:") and "/package:" in field(k, "HOME")]
    print(f"  OUR cells BOUND to a ref_var under a PACKAGE home: {len(cand)}")
    other = [(k, v) for (k, v) in ro
             if v.startswith("BOUND=ref_var:") and "/package:" not in field(k, "HOME")]
    print(f"  ... the same value under any OTHER home:            {len(other)}")
    rows = Counter(k.split("|")[0] for (k, _) in cand)
    print(f"  PREDICTED MOVING DATABASES ({len(rows)}):")
    for r, n in sorted(rows.items()):
        print(f"      {n:5d}  {r}")
    callee = Counter(field(k, "CALL").split(":", 1)[-1] for (k, _) in cand)
    mov = sum(n for c, n in callee.items() if c not in BUILTIN)
    stay = sum(n for c, n in callee.items() if c in BUILTIN)
    print(f"  PREDICTED MOVING CELLS {mov}, NOT MOVING {stay} (built-in arm):")
    for c, n in sorted(callee.items(), key=lambda kv: -kv[1]):
        print(f"      {n:5d}  {c}{'   [BUILT-IN -> does NOT move]' if c in BUILTIN else ''}")
    gb = [(k, v) for (k, v) in cand if any(x != "BARE" for x in g.get(k, {}))]
    print(f"  of the moving candidates, cells where GOLDEN is NOT bare: {len(gb)}")
    for k, v in sorted(gb):
        print("      ", k, "G=", dict(g.get(k, {})))
PY
