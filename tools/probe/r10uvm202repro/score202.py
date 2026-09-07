#!/usr/bin/env python3
"""r10uvm202repro/score202.py — the MULTISET JOIN over ct202cen rows.

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS
golden, RHS is ALWAYS ours.

Keys collide (one subroutine can appear in several package listings of one
database), so this is a MULTISET join, never a last-writer dict — RESUME §9.
`SPAN|` rows are DUMP-ONLY and are never scored.

  score202.py <golden.cen> <pristine.cen> <patched.cen> [--show] [--only=<s>]
              [--rows=CEN|IO]

prints TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / AGREE.
"""
import sys, collections

def load(path, kinds):
    m = collections.Counter()
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            k = ln.split('|', 1)[0]
            if k not in kinds:
                continue
            parts = ln.split('|', 2)          # KIND | tag | rest
            m[k + '|' + parts[2]] += 1
    return m

def keyof(row):
    return row.rsplit('|', 1)[0]

def bykey(cnt):
    d = collections.defaultdict(collections.Counter)
    for row, n in cnt.items():
        d[keyof(row)][row.rsplit('|', 1)[1]] += n
    return d

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opts = [a for a in sys.argv[1:] if a.startswith('--')]
    only = None
    kinds = {'CEN', 'IO'}
    for o in opts:
        if o.startswith('--only='):
            only = o.split('=', 1)[1]
        if o.startswith('--rows='):
            kinds = set(o.split('=', 1)[1].split(','))
    show = '--show' in opts
    g, a, b = (bykey(load(p, kinds)) for p in args[:3])
    keys = set(g) | set(a) | set(b)
    if only:
        keys = {k for k in keys if only in k}
    to_g = away = wrong = still = agree = 0
    lines = []
    for k in sorted(keys):
        gv = g.get(k, collections.Counter())
        av = a.get(k, collections.Counter())
        bv = b.get(k, collections.Counter())
        pris_ok, pat_ok = (av == gv), (bv == gv)
        if pris_ok and pat_ok:
            agree += 1
            continue
        if not pris_ok and pat_ok:
            to_g += 1; tag = 'TO-GOLDEN'
        elif pris_ok and not pat_ok:
            away += 1; tag = 'AWAY-GOLDEN'
        elif av != bv:
            wrong += 1; tag = 'MOVED-WRONG'
        else:
            still += 1; tag = 'STILL-WRONG'
        lines.append(f'{tag} {k}\n    golden={dict(gv)}\n    pris  ={dict(av)}\n    pat   ={dict(bv)}')
    if show:
        for l in lines:
            print(l)
    print(f'TO-GOLDEN {to_g}  AWAY-GOLDEN {away}  MOVED-WRONG {wrong}  '
          f'STILL-WRONG {still}  AGREE {agree}  KEYS {len(keys)}')

main()
