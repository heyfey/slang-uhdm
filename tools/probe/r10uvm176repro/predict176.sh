#!/usr/bin/env bash
# r10uvm176repro/predict176.sh — THE A-PRIORI MOVER PREDICTION, from the
# PRISTINE databases alone.  MEASUREMENT ONLY.  Run this BEFORE the patched
# sweep: a mover the pass did not name here is a mover the pass did not
# understand (RESUME.md §7).
#
#   predict176.sh <pristine face census> [<second face census> ...]
#
# The prediction is exactly the gate the law writes, read off the databases:
#   * the cell is in the FACE (a method_func_call/method_task_call with a
#     vpiPrefix and NO vpiFunction/vpiTask link);
#   * its RECEIVER is ONE NAME — no '.', no ':' — which is the receiver
#     spelling `CompileHelper::compileTfCall`'s dotted arm accepts;
#   * the reference is BARE on our side;
#   * golden BINDS it.
# A cell that meets all four is predicted to move; anything else must not.
#
# The HOME conjunct (`curSubClassScope9 && !curSubOob9`) is deliberately NOT
# applied here, so the prediction is an UPPER BOUND that also names the cells
# the home conjunct is there to protect.
set -u
python3 - "$@" <<'PY'
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


def recv(k):
    for f in k.split("|"):
        if f.startswith("RECV="):
            return f[len("RECV="):].split(":", 1)[-1]
    return ""


for p in sys.argv[1:]:
    g, o = load(p)
    cand = [k for k in o if "BARE" in o[k]
            and "." not in recv(k) and ":" not in recv(k)]
    gb = [k for k in cand if k in g and any(v.startswith("BOUND") for v in g[k])]
    gn = [k for k in cand if k not in g]
    print(f"{p}")
    print(f"  our BARE face cells with a ONE-NAME receiver : {len(cand)}")
    print(f"  PREDICTED MOVERS (golden BINDS them)         : {len(gb)}")
    print(f"    by row: {dict(Counter(k.split('|')[0] for k in gb))}")
    for k in sorted(gb):
        print("      ", k)
    print(f"  golden has NO SUCH KEY (our receiver NAME differs): {len(gn)}")
    for k in sorted(gn):
        print("      ", k)
PY
