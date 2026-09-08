#!/usr/bin/env python3
"""r10uvm204repro/score204.py — the MULTISET JOIN over ct204cen rows.

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS
golden (Surelog), RHS is ALWAYS ours.

Keys collide (one subroutine appears in several package listings of one
database, and a UVM database carries the same clone twice), so this is a
MULTISET join, never a last-writer dict — RESUME.md §9.

  score204.py <golden.cen> <pristine.cen> <patched.cen> [--show]
              [--only=<substr>] [--rows=AG,FI,AGALL]

Row families (ct204cen.cpp):
  FI|     one row per for_stmt INIT statement (form x Lhs kind x typespec)
  AG|     one row per Actual_group carrier BOUND to a for-init loop variable
  AGALL|  one row per Actual_group carrier, bound or not — the WIDE column

Default `--rows=AG,AGALL` scores the law's own family AND the wide column, so a
fix that binds something it should not is MOVED-WRONG, not invisible.

prints TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / AGREE.
"""
import sys, collections, re

# The census VALUE names the bound object's own span.  Golden SHARES one
# for-init loop variable between the home listing and every clone; we copy it.
# No generated `Compare` reads `VpiParent` (RESUME.md §9), so sharing-vs-copying
# is invisible to the judge and must not be scored as a difference — the span is
# stripped for the same reason `Compare` never reads VpiFile/line/col.
SPAN = re.compile(r'@\d+:\d+')


def load(path, kinds):
    m = collections.Counter()
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            k = ln.split('|', 1)[0]
            if k not in kinds:
                continue
            key, _, val = ln.partition('\t')
            parts = key.split('|', 2)          # KIND | tag | rest
            if len(parts) < 3:
                continue
            m[(k + '|' + parts[2], SPAN.sub('', val))] += 1
    return m


def bykey(cnt):
    d = collections.defaultdict(collections.Counter)
    for (key, val), n in cnt.items():
        d[key][val] += n
    return d


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opts = [a for a in sys.argv[1:] if a.startswith('--')]
    only = None
    kinds = {'AG', 'AGALL'}
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
        lines.append(f'{tag} {k}\n    golden={dict(gv)}\n    pris  ={dict(av)}\n'
                     f'    pat   ={dict(bv)}')
    if show:
        for l in lines:
            print(l)
    print(f'TO-GOLDEN {to_g}  AWAY-GOLDEN {away}  MOVED-WRONG {wrong}  '
          f'STILL-WRONG {still}  AGREE {agree}  KEYS {len(keys)}')


main()
