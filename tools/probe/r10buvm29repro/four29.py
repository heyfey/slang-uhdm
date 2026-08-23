#!/usr/bin/env python3
"""r10buvm29 three-way CELL scorer.  MEASUREMENT ONLY -- uhdm-cmp is the judge.

Scores golden / pristine / patched ct29cen censuses cell by cell:
  ALREADY-OK  pristine already matched golden
  FIXED       pristine differed, patched matches
  BROKE       pristine matched, patched differs      <-- must be 0
  STILL       both differ (a residue)
  EXTRA-PAT   a cell only the patched side has
  MISSING     a cell only golden has

The KEY is (line, OP) -- NOT the span.  No generated `Compare` reads
VpiFile/VpiLineNo/VpiColumnNo (RESUME.md §9), so a span difference is
invisible to the judge and must not be scored as a defect; it is reported
separately as SPAN-ONLY.  The VALUE is the judged shape: (OP, TS, NOPND,
OPNDS, PARENT).  Rows are a MULTISET (a DEF and an ELAB clone share a key).

usage: four29.py G.cen PRI.cen PAT.cen [-v]
"""
import sys
from collections import Counter, defaultdict

def load(p):
    rows = []
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 7:
            continue
        span, op, ts, n, opnds, par, owner = f[:7]
        line = span.split(":")[0]
        rows.append(((line, op, owner), (op, ts, n, opnds, par), span))
    return rows

def bag(rows):
    d = defaultdict(list)
    for k, v, span in rows:
        d[k].append((v, span))
    return d

def main():
    g, pri, pat = (bag(load(p)) for p in sys.argv[1:4])
    verbose = "-v" in sys.argv
    keys = sorted(set(g) | set(pri) | set(pat))
    tally = Counter()
    for k in keys:
        gv = Counter(v for v, _ in g.get(k, []))
        pv = Counter(v for v, _ in pri.get(k, []))
        qv = Counter(v for v, _ in pat.get(k, []))
        gs = Counter(s for _, s in g.get(k, []))
        qs = Counter(s for _, s in pat.get(k, []))
        okp, okq = (gv == pv), (gv == qv)
        if okp and okq:
            verd = "ALREADY-OK"
        elif not okp and okq:
            verd = "FIXED"
        elif okp and not okq:
            verd = "BROKE"
        elif not gv:
            verd = "EXTRA-PAT"
        elif not qv:
            verd = "MISSING"
        else:
            verd = "STILL"
        tally[verd] += 1
        if okq and gs != qs:
            tally["SPAN-ONLY"] += 1
        if verbose and verd not in ("ALREADY-OK",):
            print(f"  {verd:11s} {k}")
            for v, c in (gv - qv).items():
                print(f"      G-only x{c}: {v}")
            for v, c in (qv - gv).items():
                print(f"      P-only x{c}: {v}")
    order = ["ALREADY-OK", "FIXED", "BROKE", "STILL", "EXTRA-PAT", "MISSING",
             "SPAN-ONLY"]
    print("CELLS %d  " % len(keys) +
          "  ".join(f"{o} {tally[o]}" for o in order))

main()
