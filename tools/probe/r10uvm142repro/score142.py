#!/usr/bin/env python3
"""r10uvm142 — CLASS_TYPESPEC cell scorer.  MEASUREMENT ONLY (uhdm-cmp is the
sole acceptance judge).

  score142.py <golden.cen> <pristine.cen> [<patched.cen>]

Cells are the rows ct142cen prints, joined as a MULTISET (keys collide; a
last-writer dict drops rows) on the ID-FREE, PRODUCER-NEUTRAL key

    TSSPAN

and, within a key, ordered by (TSDEFN, SITE, PAR) — all three stable per
producer.  TSSPAN alone is the key because it is the ONE field both producers
agree on for a per-use mint (uhdm-cmp reads no location at all, so a span in
the key can only SPLIT cells the judge pairs — never merge cells it separates;
splitting shows up as ONLY-GOLDEN/ONLY-OURS and is therefore visible, not
silent).  The DEF/ELAB view and the design listing are deliberately OUT of the
key: an object listed twice is simply two bag entries on both sides.

Scored columns — exactly the fields the generated Compare chain reads:
  TSNAME   typespec::Compare          <- half of THE HEAD
  TSINST   typespec::Compare          <- the other half of THE HEAD
  TSALIAS  typespec::Compare (Typedef_alias, walked BEFORE Instance)
  TSDEFN   class_typespec::Compare
  TSCT     class_typespec::Compare (VpiClassType)
  TSAUTO   class_typespec::Compare (VpiAutomatic)
  TSPARM   class_typespec::Compare (Parameters vector size)
  TSPA     class_typespec::Compare (Param_assigns vector size)
  TSEXT    class_typespec::Compare (Extends)
dump-only diagnostics (no generated Compare reads them):
  PAR, SCOPE, DEFSPAN

Verdicts: RIGHT->RIGHT / WRONG->RIGHT (fixed) / WRONG->WRONG /
RIGHT->WRONG (MOVED-WRONG, must be 0) / ONLY-GOLDEN / ONLY-OURS /
AWAY (a key that left or entered our side BECAUSE of the patch — must be 0).
A NAME or an INSTANCE added where golden has none is not a "fix": it lands in
RIGHT->WRONG on that column, which is why the column verdicts are printed
per column and never summed.
"""
import sys, collections, os

COLS = ("TSNAME", "TSINST", "TSALIAS", "TSDEFN", "TSCT", "TSAUTO",
        "TSPARM", "TSPA", "TSEXT", "HOLD", "PAR", "SCOPE", "DEFSPAN")

# UHDM's built-in classes.  A Surelog golden built with `-nobuiltin` (every grid
# arm here) does not carry them and our exporter always does — permanent
# ONLY-OURS noise, not this pass's population.  BUILTINS=1 keeps them.
# Matched on the WHOLE Class_defn name, never as a substring: `process` is a
# substring of `uvm_cmdline_processor`, and a substring test silently hid THIS
# PASS'S OWN HEAD CELLS from the first run of this scorer.
BUILTIN = ("work@mailbox", "work@process", "work@semaphore")
KEEP_BUILTIN = os.environ.get("BUILTINS", "") == "1"

def load(p):
    rows = []
    try:
        for ln in open(p):
            ln = ln.rstrip("\n")
            if not ln.startswith("HOLD="):
                continue
            d = {}
            for f in ln.split("|"):
                if "=" in f:
                    k, v = f.split("=", 1)
                    d[k] = v
            if not KEEP_BUILTIN and d.get("TSDEFN", "") in BUILTIN:
                continue
            rows.append(d)
    except FileNotFoundError:
        pass
    return rows

def key(r):
    return (r["TSSPAN"],)

def bag(rows):
    b = collections.defaultdict(list)
    for r in rows:
        b[key(r)].append(r)
    return b

args = sys.argv[1:]
g = bag(load(args[0]))
p = bag(load(args[1]))
q = bag(load(args[2])) if len(args) > 2 else p
keys = set(g) | set(p) | set(q)
LIM = int(os.environ.get("LIM", "80"))
ONLY = os.environ.get("ONLY", "")

# The join inside a key is a MULTISET COMPARISON per column, not a positional
# zip: the two producers order a key's rows differently (our PAR / SITE differ
# on objects the judge pairs anyway), and a positional zip turns that ordering
# into phantom mismatches.  Counter deltas are order-blind and lossless.
def verdicts(gv, pv, qv):
    """gv/pv/qv are Counters of one column's values under one key."""
    out = collections.Counter()
    det = []
    # what golden asks for, matched greedily against pristine and patched
    allv = set(gv) | set(pv) | set(qv)
    # per VALUE: how many golden wants, how many we had, how many we have
    surplus_p = collections.Counter()
    surplus_q = collections.Counter()
    for v in allv:
        need, had, has = gv[v], pv[v], qv[v]
        same = min(need, had, has)
        out["RIGHT->RIGHT"] += same
        if had > need:
            surplus_p[v] += had - need
        if has > need:
            surplus_q[v] += has - need
    # deficits (golden values we are missing) on each side
    def_p = collections.Counter()
    def_q = collections.Counter()
    for v in allv:
        if gv[v] > pv[v]:
            def_p[v] += gv[v] - pv[v]
        if gv[v] > qv[v]:
            def_q[v] += gv[v] - qv[v]
    nP = sum(def_p.values()); nQ = sum(def_q.values())
    sP = sum(surplus_p.values()); sQ = sum(surplus_q.values())
    # a deficit paired with a surplus is a WRONG VALUE; an unpaired deficit is
    # ONLY-GOLDEN; an unpaired surplus is ONLY-OURS.
    wP = min(nP, sP); wQ = min(nQ, sQ)
    n = max(wP, wQ)
    for i in range(n):
        a = i < wP   # was wrong before
        b = i < wQ   # is wrong now
        if a and b:
            out["WRONG->WRONG"] += 1
        elif a and not b:
            out["WRONG->RIGHT"] += 1
        elif b and not a:
            out["RIGHT->WRONG"] += 1
    og = max(nP - wP, nQ - wQ)
    oo = max(sP - wP, sQ - wQ)
    out["ONLY-GOLDEN"] += og
    out["ONLY-OURS"] += oo
    # AWAY: a value the patch REMOVED that golden wanted, or ADDED where golden
    # has none, relative to pristine.
    if (nQ - wQ) > (nP - wP):
        out["AWAY"] += (nQ - wQ) - (nP - wP)
    if (sQ - wQ) > (sP - wP):
        out["AWAY"] += (sQ - wQ) - (sP - wP)
    if out["WRONG->WRONG"] or out["WRONG->RIGHT"] or out["RIGHT->WRONG"] or og or oo:
        det.append((dict(gv), dict(pv), dict(qv)))
    return out, det

for col in COLS:
    if ONLY and col not in ONLY.split(","):
        continue
    c = collections.Counter(); detail = []
    for k in sorted(keys):
        gv = collections.Counter(r[col] for r in g.get(k, []))
        pv = collections.Counter(r[col] for r in p.get(k, []))
        qv = collections.Counter(r[col] for r in q.get(k, []))
        o, d = verdicts(gv, pv, qv)
        c.update(o)
        for t in d:
            detail.append((k, t))
    tot = sum(c.values())
    print("%-8s TOTAL=%d %s" % (col, tot,
          " ".join("%s=%d" % (kk, c[kk]) for kk in
                   ("RIGHT->RIGHT", "WRONG->RIGHT", "WRONG->WRONG",
                    "RIGHT->WRONG", "ONLY-GOLDEN", "ONLY-OURS", "AWAY")
                   if c[kk])))
    for k, (gd, pd, qd) in detail[:LIM]:
        print("    %-14s G=%s P=%s Q=%s" % ("|".join(k), gd, pd, qd))
    if len(detail) > LIM:
        print("    ... %d more" % (len(detail) - LIM))
