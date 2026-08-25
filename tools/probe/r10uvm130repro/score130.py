#!/usr/bin/env python3
"""r10uvm130repro/score130.py — DIRECTION SCORER for one grid arm or one
census pair.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

    score130.py <cen.g.txt> <cen.pristine.txt> <cen.patched.txt>

Two cell families, both keyed on what BOTH producers can spell:

  NET  cells  key (module fullname, net span, net name)  -> IMPL / OTH / absent
  REF  cells  key (reference span, reference name, CTX)  -> the ACTIMPL column
              (IMPL when the actual is an implicit module wire, else the
              actual's kind, else NONE)

For each family it prints, over the union of keys:
    AGREE-BEFORE / AGREE-AFTER
    TO-GOLDEN    cells that DISAGREED with golden before and AGREE after
    AWAY-GOLDEN  cells that AGREED with golden before and DISAGREE after
    STILL-WRONG  cells that disagree in both
A pass may only ship AWAY-GOLDEN = 0.
"""
import sys, collections

def load(path):
    nets = collections.Counter()
    refs = collections.Counter()
    with open(path) as f:
        for line in f:
            c = line.rstrip("\n").split("\t")
            if len(c) < 3:
                continue
            if c[1] == "NET" and len(c) >= 9:
                nets[(c[4], c[5], c[6], c[3])] += 1
            elif c[1] == "REF" and len(c) >= 16:
                act = "IMPL" if c[12] == "IMPL" else c[8]
                refs[(c[6], c[7], c[14], act)] += 1
    return nets, refs

def score(name, g, a, b):
    keys = set()
    for d in (g, a, b):
        keys |= set(d)
    # collapse the multiplicity: a cell is "present" if any copy is
    gp = {k for k in g}
    ap = {k for k in a}
    bp = {k for k in b}
    agree_before = len(gp & ap) + len((keys - gp) & (keys - ap))
    agree_after = len(gp & bp) + len((keys - gp) & (keys - bp))
    to_g = away = still = 0
    moved = []
    for k in sorted(keys):
        ok_a = (k in gp) == (k in ap)
        ok_b = (k in gp) == (k in bp)
        if not ok_a and ok_b:
            to_g += 1; moved.append(("TO-GOLDEN", k))
        elif ok_a and not ok_b:
            away += 1; moved.append(("AWAY-GOLDEN", k))
        elif not ok_a and not ok_b:
            still += 1; moved.append(("STILL-WRONG", k))
    print(f"[{name}] cells={len(keys)} AGREE-BEFORE={agree_before} "
          f"AGREE-AFTER={agree_after} TO-GOLDEN={to_g} AWAY-GOLDEN={away} "
          f"STILL-WRONG={still}")
    for tag, k in moved:
        print(f"   {tag}\t{'|'.join(k)}\tg={g[k]} pris={a[k]} pat={b[k]}")

def main():
    if len(sys.argv) != 4:
        print(__doc__); return 2
    gn, gr = load(sys.argv[1])
    an, ar = load(sys.argv[2])
    bn, br = load(sys.argv[3])
    score("NET", gn, an, bn)
    score("REF", gr, ar, br)
    return 0

sys.exit(main())
