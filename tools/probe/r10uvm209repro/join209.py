#!/usr/bin/env python3
"""r10uvm209 — join209.py — MEASUREMENT ONLY.  The official uhdm-cmp is the sole
judge; this script only reports.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS
ours.

One line per arm-view from two `ct209cen` outputs:

  AGREE=<n> WRONG=<n> ONLY-GOLDEN=<n> ONLY-OURS=<n> MSET-MISSING=<n> MSET-EXTRA=<n>

AGREE/WRONG/ONLY-* score the POSITION-KEYED listing cells (the vectors the
judge walks); MSET-* score the whole-database variable MULTISET (counted, never
a dict — an import copy legitimately repeats a face).  `--diffs` prints one
`G=… O=…` line per disagreeing cell and one per multiset shortfall/excess.

Calibration is golden-vs-golden and must read AGREE=<all>, everything else 0.
"""
import sys, collections, argparse


def load(path):
    listing, multi, scope = {}, collections.Counter(), {}
    try:
        fh = open(path)
    except OSError:
        return listing, multi, scope
    with fh:
        for line in fh:
            p = line.rstrip('\n').split('\t')
            if len(p) < 3:
                continue
            if p[0] == 'VAR':
                multi[p[1]] += 1
            else:
                listing[p[0]] = p[1]
                scope[p[0]] = p[2]
    return listing, multi, scope


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('golden')
    ap.add_argument('ours')
    ap.add_argument('--diffs', action='store_true')
    a = ap.parse_args()
    gl, gm, gs = load(a.golden)
    ol, om, _ = load(a.ours)
    agree = wrong = og = oo = 0
    lines = []
    for k in sorted(gl):
        ov = ol.get(k)
        if ov is None:
            og += 1
            lines.append(f"ONLY-GOLDEN {k} G={gl[k]} scope={gs.get(k)}")
        elif ov == gl[k]:
            agree += 1
        else:
            wrong += 1
            lines.append(f"WRONG {k} G={gl[k]} O={ov} scope={gs.get(k)}")
    for k in sorted(ol):
        if k not in gl:
            oo += 1
            lines.append(f"ONLY-OURS {k} O={ol[k]}")
    miss = gm - om
    extra = om - gm
    for k, c in sorted(miss.items()):
        lines.append(f"MSET-MISSING {k} x{c}")
    for k, c in sorted(extra.items()):
        lines.append(f"MSET-EXTRA {k} x{c}")
    print(f"AGREE={agree} WRONG={wrong} ONLY-GOLDEN={og} ONLY-OURS={oo} "
          f"MSET-MISSING={sum(miss.values())} MSET-EXTRA={sum(extra.values())}")
    if a.diffs:
        for ln in lines:
            print(ln)


main()
