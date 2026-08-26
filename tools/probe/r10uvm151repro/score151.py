#!/usr/bin/env python3
"""r10uvm151 — score a ct151cen triple (golden, pristine, patched).

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

Cells are joined as MULTISETS on the ID-FREE key  FILE + ANCH  (the shape
anchor: the PREFIX's start for a prefixed method_func_call, the object's own
start otherwise — golden's degenerate `func_call` starts exactly where our
`method_func_call`'s prefix starts, which is what lets the two shapes pair
ACROSS the type flip).  Rows sharing a key are matched in sorted order.

SCORED columns:  KIND NAME PFX NARG WITH FUNC
DIAGNOSTIC only: SPAN (RESUME.md §9 — no generated Compare reads a span), PK,
and the ROWSETS line.  ROWSETS is DIAGNOSTIC and not part of the verdict
because `UhdmListener` follows BACK-REFERENCE edges (`vpiParent`, `vpiActual`)
that `uhdm-dump` only SHALLOW-visits, so a stale clone that the design merely
points at is counted here while `uhdm-cmp` cannot see it at all
(`UHDM/templates/vpi_visitor.cpp:543` builds the `\_weaklyReferenced:` tail out
of exactly those).  The AUTHORITATIVE row-set instrument is
`dumpsect151.sh` — the sorted DESIGN SECTION of the whole dump — which the
arms driver runs for every arm and view.

    score151.py golden.cen pristine.cen patched.cen
"""
import sys, collections

SCORED = ["KIND", "NAME", "PFX", "NARG", "WITH", "FUNC"]

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.strip()
        if not ln.startswith("CALL "):
            continue
        f = dict(kv.split("=", 1) for kv in ln.split()[1:] if "=" in kv)
        key = (f.get("FILE", "-"), f.get("ANCH", "-"))
        d[key].append(tuple(f.get(c, "-") for c in SCORED))
    for k in d:
        d[k].sort()
    return d

def main():
    g, o, p = (load(a) for a in sys.argv[1:4])
    col = {c: collections.Counter() for c in SCORED}
    onlyg = {"pris": 0, "pat": 0}
    onlyo = {"pris": 0, "pat": 0}
    for tag, ours in (("pris", o), ("pat", p)):
        for k in set(g) | set(ours):
            ng, no = len(g.get(k, [])), len(ours.get(k, []))
            onlyg[tag] += max(0, ng - no)
            onlyo[tag] += max(0, no - ng)
    for k in set(g) & set(o) & set(p):
        rows = min(len(g[k]), len(o[k]), len(p[k]))
        for i in range(rows):
            for ci, c in enumerate(SCORED):
                gv, ov, pv = g[k][i][ci], o[k][i][ci], p[k][i][ci]
                if ov == gv and pv == gv:
                    col[c]["RIGHT->RIGHT"] += 1
                elif ov != gv and pv == gv:
                    col[c]["WRONG->RIGHT"] += 1
                elif ov == gv and pv != gv:
                    col[c]["RIGHT->WRONG"] += 1
                elif pv == ov:
                    col[c]["WRONG->WRONG"] += 1
                else:
                    col[c]["AWAY"] += 1
    bad = 0
    for c in SCORED:
        cc = col[c]
        print("   %-5s RIGHT->RIGHT %-5d WRONG->RIGHT %-4d RIGHT->WRONG %-3d "
              "WRONG->WRONG %-3d AWAY %d" %
              (c, cc["RIGHT->RIGHT"], cc["WRONG->RIGHT"], cc["RIGHT->WRONG"],
               cc["WRONG->WRONG"], cc["AWAY"]))
        bad += cc["RIGHT->WRONG"] + cc["AWAY"]
    print("   ROWSETS ONLY-GOLDEN pris=%d pat=%d   ONLY-OURS pris=%d pat=%d" %
          (onlyg["pris"], onlyg["pat"], onlyo["pris"], onlyo["pat"]))
    if onlyg["pat"] > onlyg["pris"] or onlyo["pat"] > onlyo["pris"]:
        print("   ROWSET-GREW (diagnostic — see dumpsect151.sh for the "
              "design-section row set)")
    print("   VERDICT " + ("CLEAN" if bad == 0 else "DIRTY"))

main()
