#!/usr/bin/env python3
"""r10uvm145 — BODY / STMT / LOC cell scorer.  MEASUREMENT ONLY (uhdm-cmp is
the sole acceptance judge).

  score145.py <golden.cen> <pristine.cen> [<patched.cen>]

ct145cen prints three row kinds.  Each is joined as a MULTISET (keys collide;
a last-writer dict drops rows) on an ID-FREE, PRODUCER-NEUTRAL key:

  ROW=BODY  key (HSPAN,)          columns NSTMTS NVARS BVARS BKIND NTOPS
  ROW=STMT  key (HSPAN, SSPAN)    columns SKIND SLHS
  ROW=LOC   key (HSPAN, LNAME)    columns LKIND LAUTO LEXPR LOWN LHOIST

Spans are keys, never scored columns — uhdm-cmp reads no location at all, so a
span in the key can only SPLIT cells the judge pairs, never merge cells it
separates, and a split shows up as ONLY-GOLDEN/ONLY-OURS rather than hiding.
The DEF/ELAB view and the design listing are deliberately OUT of the key: an
object listed twice is two bag entries on both sides.

A PASS THAT REMOVES OBJECTS MUST SCORE ONE-SIDED SETS (§ 109's lesson), so
ONLY-OURS and ONLY-GOLDEN are printed for every column, and the STMT row kind
exists precisely so a REMOVED statement is counted rather than silently
absorbed into a count column.

Verdicts: RIGHT->RIGHT / WRONG->RIGHT (fixed) / WRONG->WRONG /
RIGHT->WRONG (MOVED-WRONG, must be 0) / ONLY-GOLDEN / ONLY-OURS /
AWAY (a cell that left or entered our side BECAUSE of the patch — must be 0).
"""
import sys, collections, os

KINDS = {
    "BODY": (("HSPAN",), ("NSTMTS", "NVARS", "BVARS", "BKIND", "NTOPS")),
    "STMT": (("HSPAN", "SSPAN"), ("SKIND", "SLHS", "SLHSVAR")),
    "LOC":  (("HSPAN", "LNAME"), ("LKIND", "LAUTO", "LEXPR", "LOWN", "LHOIST")),
}

# UHDM's built-in classes/subroutines.  A Surelog golden built with `-nobuiltin`
# (every grid arm here) does not carry them and our exporter always does —
# permanent ONLY-OURS noise, not this pass's population.  BUILTINS=1 keeps
# them.  Matched on the WHOLE scope string component, never as a substring.
BUILTIN_SCOPE = ("class_defn(work@mailbox)", "class_defn(work@process)",
                 "class_defn(work@semaphore)", "class_defn(mailbox)",
                 "class_defn(process)", "class_defn(semaphore)")
KEEP_BUILTIN = os.environ.get("BUILTINS", "") == "1"

def load(p):
    rows = []
    try:
        for ln in open(p):
            ln = ln.rstrip("\n")
            if not ln.startswith("ROW="):
                continue
            d = {}
            for f in ln.split("|"):
                if "=" in f:
                    k, v = f.split("=", 1)
                    d[k] = v
            if not KEEP_BUILTIN:
                sc = d.get("HSCOPE", "")
                if any(b in sc.split("/") for b in BUILTIN_SCOPE):
                    continue
            rows.append(d)
    except FileNotFoundError:
        pass
    return rows

def bag(rows, kind, keyf):
    b = collections.defaultdict(list)
    for r in rows:
        if r.get("ROW") != kind:
            continue
        b[tuple(r.get(k, "-") for k in keyf)].append(r)
    return b

def verdicts(gv, pv, qv):
    """gv/pv/qv are Counters of one column's values under one key.
    A MULTISET comparison, not a positional zip: the two producers order a
    key's rows differently and a positional zip turns ordering into phantoms."""
    out = collections.Counter()
    det = []
    allv = set(gv) | set(pv) | set(qv)
    surplus_p = collections.Counter(); surplus_q = collections.Counter()
    for v in allv:
        need, had, has = gv[v], pv[v], qv[v]
        out["RIGHT->RIGHT"] += min(need, had, has)
        if had > need: surplus_p[v] += had - need
        if has > need: surplus_q[v] += has - need
    def_p = collections.Counter(); def_q = collections.Counter()
    for v in allv:
        if gv[v] > pv[v]: def_p[v] += gv[v] - pv[v]
        if gv[v] > qv[v]: def_q[v] += gv[v] - qv[v]
    nP = sum(def_p.values()); nQ = sum(def_q.values())
    sP = sum(surplus_p.values()); sQ = sum(surplus_q.values())
    wP = min(nP, sP); wQ = min(nQ, sQ)
    for i in range(max(wP, wQ)):
        a = i < wP; b = i < wQ
        if a and b: out["WRONG->WRONG"] += 1
        elif a: out["WRONG->RIGHT"] += 1
        else: out["RIGHT->WRONG"] += 1
    og = max(nP - wP, nQ - wQ); oo = max(sP - wP, sQ - wQ)
    out["ONLY-GOLDEN"] += og
    out["ONLY-OURS"] += oo
    if (nQ - wQ) > (nP - wP): out["AWAY"] += (nQ - wQ) - (nP - wP)
    if (sQ - wQ) > (sP - wP): out["AWAY"] += (sQ - wQ) - (sP - wP)
    if out["WRONG->WRONG"] or out["WRONG->RIGHT"] or out["RIGHT->WRONG"] or og or oo:
        det.append((dict(gv), dict(pv), dict(qv)))
    return out, det

args = sys.argv[1:]
G = load(args[0]); P = load(args[1]); Q = load(args[2]) if len(args) > 2 else P
LIM = int(os.environ.get("LIM", "60"))
ONLY = os.environ.get("ONLY", "")

for kind, (keyf, cols) in KINDS.items():
    g = bag(G, kind, keyf); p = bag(P, kind, keyf); q = bag(Q, kind, keyf)
    keys = set(g) | set(p) | set(q)
    # ONE-SIDED SETS, counted as SETS OF ROWS and not per column: a statement
    # that exists only on our side is a ROW, and the whole point of this pass.
    onlyG = sum(max(0, len(g.get(k, [])) - len(q.get(k, []))) for k in keys)
    onlyO = sum(max(0, len(q.get(k, [])) - len(g.get(k, []))) for k in keys)
    onlyGp = sum(max(0, len(g.get(k, [])) - len(p.get(k, []))) for k in keys)
    onlyOp = sum(max(0, len(p.get(k, [])) - len(g.get(k, []))) for k in keys)
    print("ROW=%-5s keys=%d  ROWSETS pristine[ONLY-GOLDEN=%d ONLY-OURS=%d]"
          "  patched[ONLY-GOLDEN=%d ONLY-OURS=%d]"
          % (kind, len(keys), onlyGp, onlyOp, onlyG, onlyO))
    for k in sorted(keys):
        dg, dp, dq = len(g.get(k, [])), len(p.get(k, [])), len(q.get(k, []))
        if dg != dq or dg != dp:
            print("    ROWSET %-28s G=%d P=%d Q=%d" % ("|".join(k), dg, dp, dq))
    for col in cols:
        if ONLY and col not in ONLY.split(","):
            continue
        c = collections.Counter(); detail = []
        for k in sorted(keys):
            gv = collections.Counter(r.get(col, "-") for r in g.get(k, []))
            pv = collections.Counter(r.get(col, "-") for r in p.get(k, []))
            qv = collections.Counter(r.get(col, "-") for r in q.get(k, []))
            o, d = verdicts(gv, pv, qv)
            c.update(o)
            for t in d:
                detail.append((k, t))
        tot = sum(c.values())
        print("  %-8s TOTAL=%d %s" % (col, tot,
              " ".join("%s=%d" % (kk, c[kk]) for kk in
                       ("RIGHT->RIGHT", "WRONG->RIGHT", "WRONG->WRONG",
                        "RIGHT->WRONG", "ONLY-GOLDEN", "ONLY-OURS", "AWAY")
                       if c[kk])))
        for k, (gd, pd, qd) in detail[:LIM]:
            print("      %-28s G=%s P=%s Q=%s" % ("|".join(k), gd, pd, qd))
        if len(detail) > LIM:
            print("      ... %d more" % (len(detail) - LIM))
