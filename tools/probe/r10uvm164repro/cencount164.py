#!/usr/bin/env python3
"""r10uvm164 -- the CORPUS census counter.  MEASUREMENT ONLY.
G is ALWAYS golden (Surelog), O is ALWAYS ours.

Reads the per-row census files census164.sh wrote and cross-tabulates EVERY
reference that sits under a CAST, keyed by

    CONTEXT (ifcond / casecond / caseitem / assertcond / assign_lhs /
             assign_rhs / arg / return / loopcond / evctrl / waitcond / body)
  x HOME    (function|task|initial|always @ class_defn|package|module_inst|...)
  x CAST    (castop / signcast / a nested chain)

with, per cell, golden's value and ours.  The join is a MULTISET join on
(ctx, cast, home, kind, name, span): keys collide (the same source line is
emitted twice, once per view), and a last-writer dict would drop rows
(RESUME.md S9's census trap), so both sides are counted as Counters and the
difference is reported per value.

BOTH ONE-SIDED SETS are reported: ONLY-G (a cast reference golden has and we do
not) and ONLY-O (one we have and golden does not) -- a census that reports only
the intersection cannot see a reshape.

usage: cencount164.py <cendir> [<cendir2> ...]
       (a second dir is the PATCHED census; the cells are then also scored
        TOWARD / AWAY / SIDEWAYS against golden)
"""
import sys, os, glob, collections

def load(path):
    c = collections.Counter()
    with open(path) as f:
        for line in f:
            if not line.startswith("CAS|"):
                continue
            p = line.rstrip("\n").split("|")
            # CAS|tag|CTX=..|CAST=..|HOME=..|kind|name|span|val
            if p[3] == "CAST=none":
                continue
            key = (p[2][4:], p[3][5:], p[4][5:], p[5], p[6], p[7])
            c[(key, p[8])] += 1
    return c

def rows(cendir):
    out = {}
    for g in sorted(glob.glob(os.path.join(cendir, "*.g.txt"))):
        row = os.path.basename(g)[:-6]
        o = g[:-6] + ".o.txt"
        if not os.path.exists(o):
            print("MISSING-OURS", row)
            continue
        out[row] = (load(g), load(o))
    return out

dirs = [a for a in sys.argv[1:] if not a.startswith("--")]
if not dirs:
    print(__doc__); sys.exit(2)

P = rows(dirs[0])
Q = rows(dirs[1]) if len(dirs) > 1 else None

ctx_tab = collections.Counter()
home_tab = collections.Counter()
cast_tab = collections.Counter()
onlyG = collections.Counter()
onlyO = collections.Counter()
diffcells = []
moved = collections.Counter()
movedrows = []

for row, (G, O) in sorted(P.items()):
    gk = collections.Counter()
    ok = collections.Counter()
    for (key, val), n in G.items():
        gk[(key, val)] += n
    for (key, val), n in O.items():
        ok[(key, val)] += n
    allkeys = set(k for (k, v) in gk) | set(k for (k, v) in ok)
    for key in sorted(allkeys):
        gv = {v: n for (k, v), n in gk.items() if k == key}
        ov = {v: n for (k, v), n in ok.items() if k == key}
        ctx, cast, home = key[0], key[1], key[2]
        tot = max(sum(gv.values()), sum(ov.values()))
        ctx_tab[(ctx, "cells")] += tot
        home_tab[(home, "cells")] += tot
        cast_tab[(cast, "cells")] += tot
        if not gv:
            onlyO[(ctx, home, cast)] += sum(ov.values()); continue
        if not ov:
            onlyG[(ctx, home, cast)] += sum(gv.values()); continue
        if gv != ov:
            ctx_tab[(ctx, "DIFF")] += 1
            home_tab[(home, "DIFF")] += 1
            cast_tab[(cast, "DIFF")] += 1
            diffcells.append((row, key, sorted(gv.items()), sorted(ov.items())))
        if Q and row in Q:
            _, O2 = Q[row]
            o2 = {v: n for (k, v), n in
                  ((kk, nn) for kk, nn in O2.items()) if k == key} if False else None
            q2 = collections.Counter()
            for (k2, v2), n2 in O2.items():
                if k2 == key:
                    q2[v2] += n2
            if dict(q2) != ov:
                verdict = ("TOWARD" if dict(q2) == gv else
                           "AWAY" if ov == gv else "SIDEWAYS")
                moved[verdict] += 1
                movedrows.append((verdict, row, key, gv, ov, dict(q2)))

print("=== CELLS BY CONTEXT (references under a cast) ===")
for k in sorted(set(c for c, _ in ctx_tab)):
    print(f"  {k:<12} cells={ctx_tab[(k,'cells')]:6d}  DIFF(g!=o)={ctx_tab[(k,'DIFF')]:5d}")
print("=== CELLS BY HOME ===")
for k in sorted(set(c for c, _ in home_tab)):
    print(f"  {k:<28} cells={home_tab[(k,'cells')]:6d}  DIFF={home_tab[(k,'DIFF')]:5d}")
print("=== CELLS BY CAST KIND ===")
for k in sorted(set(c for c, _ in cast_tab)):
    print(f"  {k:<20} cells={cast_tab[(k,'cells')]:6d}  DIFF={cast_tab[(k,'DIFF')]:5d}")
print(f"=== ONE-SIDED SETS ===  ONLY-G keys={len(onlyG)} cells={sum(onlyG.values())}"
      f"   ONLY-O keys={len(onlyO)} cells={sum(onlyO.values())}")
for k, n in sorted(onlyG.items()):
    print(f"  ONLY-G {k} x{n}")
for k, n in sorted(onlyO.items()):
    print(f"  ONLY-O {k} x{n}")
print(f"=== DIFF CELLS (golden != ours), {len(diffcells)} ===")
for row, key, gv, ov in diffcells:
    print(f"  {row}\n     {key}\n     G={gv}  O={ov}")
if Q:
    print("=== MOVED (pristine -> patched) ===")
    for v, row, key, gv, ov, qv in movedrows:
        print(f"  {v:9s} {row} {key}\n     G={gv} pris={ov} pat={qv}")
    print("MOVED " + "  ".join(f"{k}={v}" for k, v in sorted(moved.items()))
          + f"   TOTAL={sum(moved.values())}")
