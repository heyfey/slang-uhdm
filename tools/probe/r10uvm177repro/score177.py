#!/usr/bin/env python3
"""r10uvm177 — the GRID SCORER.  MEASUREMENT ONLY.

Reads a grid177.sh workdir's six censuses (g/a/b x def/elab) and prints one row
per RETURN POSITION with golden's answer beside each binary's, plus the
per-binary score.  LHS is ALWAYS golden (Surelog).

A cell is:   RVKIND | TSKIND | TSNAME        (span shown but never scored:
`uhdm-cmp` reads no span).

usage: score177.py <workdir> [--list] [--span] [--only SUBSTR]
"""
import sys
import os
from collections import Counter


def load(p, use_span):
    d = {}
    if not os.path.exists(p):
        return d
    with open(p, errors='replace') as f:
        for ln in f:
            if ln.startswith('#'):
                continue
            c = ln.rstrip('\n').split('\t')
            if len(c) < 9:
                continue
            k = (c[0], c[1], c[2], c[3])
            v = (c[4], c[6], c[7]) + ((c[8],) if use_span else ())
            d.setdefault(k, []).append(v)
    return d


def main():
    W = sys.argv[1]
    show = '--list' in sys.argv
    use_span = '--span' in sys.argv
    only = None
    if '--only' in sys.argv:
        only = sys.argv[sys.argv.index('--only') + 1]
    for v in ('def', 'elab'):
        G = load(f'{W}/cen.g.{v}.txt', use_span)
        A = load(f'{W}/cen.a.{v}.txt', use_span)
        B = load(f'{W}/cen.b.{v}.txt', use_span)
        keys = sorted(set(G) | set(A) | set(B))
        sc = Counter()
        rows = []
        for k in keys:
            g = sorted(G.get(k, []))
            a = sorted(A.get(k, []))
            b = sorted(B.get(k, []))
            oka = (g == a)
            okb = (g == b)
            sc['n'] += 1
            sc['a_ok'] += oka
            sc['b_ok'] += okb
            if oka and not okb:
                sc['MOVED-WRONG'] += 1
            if okb and not oka:
                sc['FIXED'] += 1
            if not oka and not okb and a != b:
                sc['MOVED-STILL-WRONG'] += 1
            rows.append((k, g, a, b, oka, okb))
        print(f'== view={v}  positions={sc["n"]}  A(pristine)_ok={sc["a_ok"]} '
              f'B(patched)_ok={sc["b_ok"]}  FIXED={sc["FIXED"]} '
              f'MOVED-WRONG={sc["MOVED-WRONG"]} '
              f'MOVED-STILL-WRONG={sc["MOVED-STILL-WRONG"]}')
        if show:
            for k, g, a, b, oka, okb in rows:
                if only and only not in str(k):
                    continue
                mark = ('..' if oka else 'A!') + ('..' if okb else 'B!')
                print(f'  {mark} {k}\n        G={g}\n        A={a}\n        B={b}')


main()
