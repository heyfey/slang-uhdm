#!/usr/bin/env python3
"""r10uvm151 — THE A-PRIORI MOVER PREDICTION and THE CORPUS CENSUS.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

Reads the ct151cen output of a whole sweep (censweep151.sh's <tag>.g.cen /
<tag>.o.cen pairs) and, WITHOUT the patched binary existing, names every
database the law will move and every cell inside it.

THE PREDICATE, read off GOLDEN + PRISTINE alone:

    at one ID-FREE key (FILE, ANCH)
      golden  KIND=FC   PFX=-   NARG=0  WITH=0  FUNC=0
      ours    KIND=MFC  PFX=<a name>

  — golden's bare receiver-named `func_call` paired with our
  method-named `method_func_call`, at the anchor they share (the prefix's
  start on our side, the call's own start on golden's).  That IS the law's
  cell, and nothing else in either database has that pair of shapes.

With a third argument (the PATCHED census dir) the same joiner scores the
whole population WRONG->RIGHT / RIGHT->WRONG / AWAY / WRONG->WRONG per column
and prints the one-sided row-set counts, so the prediction and the measurement
are the SAME code reading the SAME keys.

    pred151.py <cen-dir> [<patched-cen-dir>]
"""
import sys, os, collections

SCORED = ["KIND", "NAME", "PFX", "NARG", "WITH", "FUNC"]

def load(p):
    d = collections.defaultdict(list)
    if not os.path.exists(p):
        return None
    for ln in open(p):
        if not ln.startswith("CALL "):
            continue
        f = dict(kv.split("=", 1) for kv in ln.split()[1:] if "=" in kv)
        d[(f.get("FILE", "-"), f.get("ANCH", "-"))].append(
            tuple(f.get(c, "-") for c in SCORED))
    for k in d:
        d[k].sort()
    return d

def is_law_cell(gv, ov):
    return (gv[0] == "FC" and gv[2] == "-" and gv[3] == "0" and
            gv[4] == "0" and gv[5] == "0" and
            ov[0] == "MFC" and ov[2] != "-")

def main():
    cendir = sys.argv[1]
    patdir = sys.argv[2] if len(sys.argv) > 2 else None
    tags = sorted({f[:-6] for f in os.listdir(cendir) if f.endswith(".g.cen")})
    col = {c: collections.Counter() for c in SCORED}
    percells = collections.Counter()
    sites = collections.Counter()
    onlyg = {"pris": 0, "pat": 0}
    onlyo = {"pris": 0, "pat": 0}
    ndb = 0
    for t in tags:
        g = load(os.path.join(cendir, t + ".g.cen"))
        o = load(os.path.join(cendir, t + ".o.cen"))
        if g is None or o is None:
            continue
        ndb += 1
        p = load(os.path.join(patdir, t + ".o.cen")) if patdir else None
        for tag, ours in (("pris", o), ("pat", p)):
            if ours is None:
                continue
            for k in set(g) | set(ours):
                ng, no = len(g.get(k, [])), len(ours.get(k, []))
                onlyg[tag] += max(0, ng - no)
                onlyo[tag] += max(0, no - ng)
        for k in set(g) & set(o):
            rows = min(len(g[k]), len(o[k]))
            for i in range(rows):
                gv, ov = g[k][i], o[k][i]
                if is_law_cell(gv, ov):
                    percells[t] += 1
                    sites[(k[0], k[1], gv[1])] += 1
                if p is not None and k in p and i < len(p[k]):
                    pv = p[k][i]
                    for ci, c in enumerate(SCORED):
                        if ov[ci] == gv[ci] and pv[ci] == gv[ci]:
                            col[c]["RIGHT->RIGHT"] += 1
                        elif ov[ci] != gv[ci] and pv[ci] == gv[ci]:
                            col[c]["WRONG->RIGHT"] += 1
                        elif ov[ci] == gv[ci] and pv[ci] != gv[ci]:
                            col[c]["RIGHT->WRONG"] += 1
                        elif pv[ci] == ov[ci]:
                            col[c]["WRONG->WRONG"] += 1
                        else:
                            col[c]["AWAY"] += 1
    print("DATABASES-WITH-BOTH %d" % ndb)
    print("PREDICTED-MOVER-DATABASES %d  PREDICTED-CELLS %d" %
          (len(percells), sum(percells.values())))
    for t, n in sorted(percells.items()):
        print("   MOVER %-60s cells=%d" % (t, n))
    print("DISTINCT-SOURCE-SITES %d" % len(sites))
    for s, n in sorted(sites.items()):
        print("   SITE %s:%s name=%s x%d" % (s[0], s[1], s[2], n))
    if patdir:
        for c in SCORED:
            cc = col[c]
            print("   %-5s RIGHT->RIGHT %-7d WRONG->RIGHT %-5d RIGHT->WRONG %-3d "
                  "WRONG->WRONG %-4d AWAY %d" %
                  (c, cc["RIGHT->RIGHT"], cc["WRONG->RIGHT"],
                   cc["RIGHT->WRONG"], cc["WRONG->WRONG"], cc["AWAY"]))
        print("   ROWSETS ONLY-GOLDEN pris=%d pat=%d   ONLY-OURS pris=%d pat=%d"
              % (onlyg["pris"], onlyg["pat"], onlyo["pris"], onlyo["pat"]))

main()
