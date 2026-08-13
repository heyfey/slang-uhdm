#!/usr/bin/env python3
"""r10earl40 — the GRID printer: golden vs ours, cell for cell, view-keyed.

usage: grid40.py <g.cells> <o.cells> [<p.cells>]

Rows whose RHS is `<null>` are the def-view rendering of a VARIABLE
DECLARATION (uhdm-dump prints `logic x;` inside a generate body as an
`assignment` with a vpiLhs and no vpiRhs) and are dropped — they are not
cells.

Prints, per (cell, view): SAME when golden and ours agree byte-for-byte on the
whole subtree signature, else the two signatures.  With a third file it also
prints the PATCHED column and the verdict MOVED / HOLD / REGRESSED / STILL.
"""
import sys
from collections import defaultdict


def load(p):
    d = defaultdict(list)
    for ln in open(p, errors='replace'):
        parts = ln.rstrip('\n').split(None, 2)
        if len(parts) < 3:
            continue
        cell, view, s = parts
        if s == '<null>':
            continue
        d[(cell, view)].append(s)
    # multiset -> sorted tuple so ELAB repeats (one per gen instance) compare
    return {k: tuple(sorted(v)) for k, v in d.items()}


def kindof(sigs):
    return ','.join(sorted({s.split('{')[0].split('@')[0] for s in sigs}))


def main():
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    p = load(sys.argv[3]) if len(sys.argv) > 3 else None
    keys = sorted(set(g) | set(o) | (set(p) if p else set()))
    nsame = nmoved = nhold = nreg = nstill = 0
    for k in keys:
        gv, ov = g.get(k), o.get(k)
        pv = p.get(k) if p else None
        cell, view = k
        if p is None:
            tag = 'SAME' if gv == ov else 'DIFF'
            if gv == ov:
                nsame += 1
            print('%-26s %-4s %s' % (cell, view, tag))
            if gv != ov:
                print('        G: %s' % (gv,))
                print('        O: %s' % (ov,))
            continue
        if gv == ov and gv == pv:
            v = 'HOLD-OK'
            nhold += 1
        elif gv != ov and gv == pv:
            v = 'MOVED'
            nmoved += 1
        elif gv == ov and gv != pv:
            v = 'REGRESSED'
            nreg += 1
        else:
            v = 'STILL-DIFF'
            nstill += 1
        print('%-26s %-4s %-11s %s' % (cell, view, v, kindof(pv or ())))
        if v in ('REGRESSED', 'STILL-DIFF'):
            print('        G: %s' % (gv,))
            print('        P: %s' % (pv,))
    print()
    if p is None:
        print('TOTALS: cells=%d SAME=%d DIFF=%d' % (len(keys), nsame,
                                                    len(keys) - nsame))
    else:
        print('TOTALS: cells=%d MOVED=%d HOLD-OK=%d REGRESSED=%d STILL-DIFF=%d'
              % (len(keys), nmoved, nhold, nreg, nstill))


if __name__ == '__main__':
    main()
