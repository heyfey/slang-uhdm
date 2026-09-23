#!/usr/bin/env python3
"""r11u102 NAME-KEYED cell scorer — every `cont_assign` (net-decl-assign AND
written `assign`) and every `param_assign`, at ANY depth, keyed on
(section, assign kind, LHS full name), with the RHS OBJECT KIND as a field.

Why a new reader.  `nda97.py` walks only column-2 `cont_assign`s, so the cells
of a CHILD instance (printed nested under the top instance) are invisible to it,
and it scores no field of a cell whose golden RHS is not a constant.  This pass
moves exactly those cells: LAW B turns a `func_call`/`sys_func_call` into a
LOCATION-LESS constant (RV97-2: a location-keyed scorer cannot see it), and
LAW C turns a constant back into the `ref_obj` golden writes.  So the KIND is a
scored field, and a `ref_obj` is scored on its written NAME and the KIND of its
`vpiActual` — the two things `ref_obj::Compare` reads.

Fields: K (rhs kind), vp/vd (value prefix/digits), ct, sz, d (decompile),
nm (ref vpiName), act (ref actual kind).  Keys whose multiplicity differs
between the three dumps are SKIPped and listed, never guessed at.

usage: nda102.py <golden.dump> <before.dump> <after.dump> [--cells]
       swap before/after for the positive control: every TO becomes an AWAY.
"""
import collections
import re
import sys

FIELDS = ('K', 'vp', 'vd', 'ct', 'sz', 'd', 'nm', 'act')
HEAD = re.compile(r'^(\s*)\\_(cont_assign|param_assign): ')


def ind(l):
    return len(l) - len(l.lstrip(' '))


def rhs_cell(L, j, base):
    """L[j] is the `\\_kind:` line of the RHS at indent `base`."""
    m = re.match(r'\s*\\_(\w+):', L[j])
    kind = m.group(1) if m else '?'
    f = dict(K=kind, vp='-', vd='-', ct='-', sz='-', d='-', nm='-', act='-')
    k = j + 1
    while k < len(L) and ind(L[k]) > base:
        l = L[k]
        if ind(l) == base + 2:
            s = l.strip()
            mv = re.match(r'\|(INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):(.*)', s)
            if mv:
                f['vp'], f['vd'] = mv.group(1), mv.group(2)
            elif s.startswith('|vpiConstType:'):
                f['ct'] = s.split(':', 1)[1]
            elif s.startswith('|vpiSize:'):
                f['sz'] = s.split(':', 1)[1]
            elif s.startswith('|vpiDecompile:'):
                f['d'] = s.split(':', 1)[1]
            elif s.startswith('|vpiName:'):
                f['nm'] = s.split(':', 1)[1]
            elif s == '|vpiActual:' and k + 1 < len(L):
                ma = re.match(r'\s*\\_(\w+):', L[k + 1])
                f['act'] = ma.group(1) if ma else '?'
        k += 1
    return tuple(f[x] for x in FIELDS)


def read(p):
    L = open(p, errors='replace').read().split('\n')
    res = collections.defaultdict(list)
    sec = '?'
    for i, l in enumerate(L):
        ms = re.match(r'\|(uhdm\w+):', l)
        if ms:
            sec = ms.group(1)
            continue
        m = HEAD.match(l)
        if not m:
            continue
        base = len(m.group(1))
        j = i + 1
        blk = []
        while j < len(L) and ind(L[j]) > base:
            blk.append(j)
            j += 1
        if not blk:
            continue
        lhs, rhs, nda = None, None, False
        for q in blk:
            if ind(L[q]) != base + 2:
                continue
            s = L[q].strip()
            if s == '|vpiNetDeclAssign:1':
                nda = True
            elif s == '|vpiLhs:' and q + 1 < len(L):
                ml = re.match(r'\s*\\_\w+: \(([^)]*)\)', L[q + 1])
                lhs = ml.group(1) if ml else None
            elif s == '|vpiRhs:' and q + 1 < len(L):
                rhs = rhs_cell(L, q + 1, base + 2)
        if lhs is None or rhs is None:
            continue
        kind = 'nda' if nda else ('ca' if m.group(2) == 'cont_assign' else 'pa')
        res[(sec, kind, lhs)].append(rhs)
    return {k: sorted(v) for k, v in res.items()}


def fmt(c):
    if c[0] == 'constant':
        return f'{c[1]}:{c[2]} ct{c[3]} sz{c[4]} d[{c[5]}]'
    if c[0] == 'ref_obj':
        return f'ref_obj nm={c[6]} act={c[7]}'
    return c[0]


def main():
    g, a, b = (read(x) for x in sys.argv[1:4])
    cells = '--cells' in sys.argv
    tot = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, SKIP=0)
    skipped = []
    for k in sorted(set(g) | set(a) | set(b)):
        G, A, B = g.get(k, []), a.get(k, []), b.get(k, [])
        if not (len(G) == len(A) == len(B)):
            tot['SKIP'] += 1
            skipped.append(f'SKIP {k} n={len(G)}/{len(A)}/{len(B)}')
            continue
        marks = []
        for fi, fn in enumerate(FIELDS):
            gv = sorted(x[fi] for x in G)
            av = sorted(x[fi] for x in A)
            bv = sorted(x[fi] for x in B)
            if av == gv and bv == gv:
                tot['EQ'] += 1
            elif av != gv and bv == gv:
                tot['TO'] += 1
                marks.append('TO:' + fn)
            elif av == gv and bv != gv:
                tot['AWAY'] += 1
                tot['MWRONG'] += 1
                marks.append('AWAY:' + fn)
            elif av == bv:
                tot['STILL'] += 1
            else:
                tot['STILL'] += 1
                tot['MWRONG'] += 1
                marks.append('MOVED-WRONG:' + fn)
        if marks or cells:
            nm = k[2].split('.')[-1] if k[1] != 'pa' else k[2]
            print(f'{k[0][4:]:12s} {k[1]:3s} {nm:24s} '
                  f'G[{" | ".join(fmt(x) for x in G)}] '
                  f'A[{" | ".join(fmt(x) for x in A)}] '
                  f'B[{" | ".join(fmt(x) for x in B)}] ' + ' '.join(marks))
    for s in skipped:
        print(s)
    print('  '.join(f'{k}={v}' for k, v in tot.items()))


main()
