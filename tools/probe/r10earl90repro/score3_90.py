#!/usr/bin/env python3
"""r10earl90 — the 3-WAY per-cell verdict for one arm.  MEASUREMENT ONLY.

Reads golden / pristine / patched `ct84cen` rows for one arm and prints, per
cell (KEY = the select's span + slot + kind + INHP + context), whether the
patch moved it TOWARD golden, AWAY from it, or not at all:

    SAME->SAME    both binaries already equalled golden
    WRONG->RIGHT  pristine differed, patched equals golden
    RIGHT->WRONG  pristine equalled golden, patched differs      <- must be 0
    WRONG->WRONG  both differ, and identically
    WRONG->OTHER  both differ, differently
    G-ONLY/O-ONLY the key exists on one side only

The join is a MULTISET (a last-writer dict drops colliding rows).  The payload
carries no span-derived field.

  usage: score3_90.py <armdir> [--cells] [--only <substr>]
"""
import sys, os, collections

def load(p):
    rows = []
    if not os.path.exists(p):
        return rows
    for line in open(p):
        line = line.rstrip("\n")
        if "\t||\t" not in line:
            continue
        k, v = line.split("\t||\t", 1)
        rows.append((k, v))
    return rows

def bykey(rows):
    d = collections.defaultdict(list)
    for k, v in rows:
        d[k].append(v)
    for k in d:
        d[k].sort()
    return d

def main():
    D = sys.argv[1]
    cells = "--cells" in sys.argv
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    g = bykey(load(os.path.join(D, "g.rows")))
    o = bykey(load(os.path.join(D, "o.rows")))
    q = bykey(load(os.path.join(D, "q.rows")))
    T = collections.Counter()
    for k in sorted(set(g) | set(o) | set(q)):
        if only and only not in k:
            continue
        gl, ol, ql = g.get(k, []), o.get(k, []), q.get(k, [])
        n = max(len(gl), len(ol), len(ql))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            qv = ql[i] if i < len(ql) else None
            if gv is None:
                v = "O-ONLY"
            elif ov is None or qv is None:
                v = "G-ONLY"
            elif ov == gv and qv == gv:
                v = "SAME->SAME"
            elif ov != gv and qv == gv:
                v = "WRONG->RIGHT"
            elif ov == gv and qv != gv:
                v = "RIGHT->WRONG"
            elif ov == qv:
                v = "WRONG->WRONG"
            else:
                v = "WRONG->OTHER"
            T[v] += 1
            if cells and v != "SAME->SAME":
                print("%-13s %s\n      G %s\n      O %s\n      Q %s" %
                      (v, k.replace("\t", " "), gv, ov, qv))
    for k in ("SAME->SAME", "WRONG->RIGHT", "RIGHT->WRONG", "WRONG->WRONG",
              "WRONG->OTHER", "G-ONLY", "O-ONLY"):
        print("%-14s %d" % (k, T[k]), file=sys.stderr)

main()
