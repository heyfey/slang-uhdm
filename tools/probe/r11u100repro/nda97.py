#!/usr/bin/env python3
"""r11u97 net-decl-assign cell scorer — r11u94's `nda94.py` with the MULTISET
TRAP closed and the NO-FOLD cell named.

`nda94.py` reads a fixed 40-line window after each `vpiNetDeclAssign:1` and
takes the FIRST `\\_constant:` + `\\_logic_net:` pair it finds there.  When a
cell's RHS is NOT a constant — Surelog declining to fold, so it writes a
`ref_obj` to the parameter instead — that window runs on into the NEXT cell and
the scorer silently attributes the neighbour's constant to the absent one: the
FALLING-COUNT trap, measured here on `'1 << 1`, `(12 ^ 10) + 1` and the `'x`
arms, every one of which golden leaves UNFOLDED.

This reader walks the `\\_cont_assign:` blocks themselves, keys each on its
`vpiLhs` net NAME, and records the RHS's OBJECT KIND.  A cell whose GOLDEN rhs
is not a constant is scored on NO FIELD at all and reported as `NOFOLD`:
GOLDEN WRITES NOTHING THERE, so neither binary can be right or wrong about a
field, and a scorer that pretended otherwise would manufacture phantoms.

usage: nda97.py <golden.dump> <tagA.dump> <tagB.dump>
       (A = the BEFORE binary, B = the AFTER binary; swap them for the
        positive control — every TO must become an AWAY.)
"""
import re
import sys

FIELDS = ('v', 'ct', 'sz', 'd')


def read(p):
    L = open(p, errors='replace').read().split('\n')
    res = {}
    for i, l in enumerate(L):
        if not re.match(r'^  \\_cont_assign: ', l):
            continue
        j = i + 1
        blk = []
        while j < len(L) and not re.match(r'^  [\\|]', L[j]):
            blk.append(L[j])
            j += 1
        blk = '\n'.join(blk)
        if '|vpiNetDeclAssign:1' not in blk:
            continue
        mn = re.search(r'\|vpiLhs:\s*\n\s*\\_logic_net: \(([^)]*)\)', blk)
        if not mn:
            continue
        n = mn.group(1).split('.')[-1]
        mr = re.search(r'\|vpiRhs:\s*\n\s*\\_([a-z_]+):(.*?)(?=\n\s*\|vpiLhs:)',
                       blk, re.S)
        if not mr:
            res[n] = {'kind': 'none'}
            continue
        kind, c = mr.group(1), mr.group(2)
        if kind != 'constant':
            res[n] = {'kind': kind}
            continue
        d = re.search(r'\|vpiDecompile:([^\n]*)', c)
        s = re.search(r'\|vpiSize:(-?\d+)', c)
        v = re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):[^\n]*)', c)
        t = re.search(r'\|vpiConstType:(\d+)', c)
        res[n] = {'kind': 'constant',
                  'v': v.group(1) if v else '?',
                  'ct': t.group(1) if t else '?',
                  'sz': s.group(1) if s else '?',
                  'd': d.group(1) if d else '?'}
    return res


def main():
    g, a, b = (read(x) for x in sys.argv[1:4])
    tot = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, MISSING=0, NOFOLD=0,
               SHAPE=0)
    for n in sorted(g):
        G, A, B = g[n], a.get(n), b.get(n)
        if A is None or B is None:
            tot['MISSING'] += 1
            print(f'{n:9s} MISSING on one side')
            continue
        if G['kind'] != 'constant':
            tot['NOFOLD'] += 1
            print(f'{n:9s} NOFOLD golden={G["kind"]:<12s} '
                  f'A={A["kind"]:<12s} B={B["kind"]}'
                  + ('   *** SHAPE MOVED ***'
                     if A['kind'] != B['kind'] else ''))
            if A['kind'] != B['kind']:
                tot['SHAPE'] += 1
            continue
        if A['kind'] != 'constant' or B['kind'] != 'constant':
            tot['SHAPE'] += 1
            print(f'{n:9s} SHAPE golden=constant A={A["kind"]} B={B["kind"]}')
            continue
        marks = []
        for f in FIELDS:
            if A[f] == G[f] and B[f] == G[f]:
                tot['EQ'] += 1
            elif A[f] != G[f] and B[f] == G[f]:
                tot['TO'] += 1
                marks.append('TO:' + f)
            elif A[f] == G[f] and B[f] != G[f]:
                tot['AWAY'] += 1
                marks.append('AWAY:' + f)
                tot['MWRONG'] += 1
            elif A[f] == B[f]:
                tot['STILL'] += 1
            else:
                tot['STILL'] += 1
                tot['MWRONG'] += 1
                marks.append('MOVED-WRONG:' + f)
        if marks:
            print(f'{n:9s} g[{G["v"]} ct{G["ct"]} sz{G["sz"]} d{G["d"]}] '
                  f'A[{A["v"]} ct{A["ct"]} sz{A["sz"]} d{A["d"]}] '
                  f'B[{B["v"]} ct{B["ct"]} sz{B["sz"]} d{B["d"]}] '
                  + ' '.join(marks))
    print('  '.join(f'{k}={v}' for k, v in tot.items()))


main()
