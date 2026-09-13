#!/usr/bin/env python3
"""r11u10 — A-PRIORI MOVER PREDICTION from the PRISTINE databases.

§ unpackedStructArrPatOneElemFold removes exactly one shape: an elaborated
copy of an unpacked-array-of-packed-struct parameter whose DEFINITION copy has
TWO OR MORE nested element patterns but whose elaborated copy we FLATTENED
into one leaf-only operand vector.  This scanner finds that shape, by name,
before the law is built.

Usage: predict10.py <workdir>/<mode> [...]        -> one line per hit
       (each argument is a verify_golden mode directory of `<test>-<hash>`
       subdirectories, each holding `slang.uhdm`)

A row is PREDICTED TO MOVE when, for one parameter name, some listing carries
`op75` with K>=2 operands that are THEMSELVES op75 (the definition tree) and
another listing carries `op75` with a leaf-only operand vector (our flat
fold).  Rows with K==1 are the one-element shape the law KEEPS and must NOT
appear.
"""
import os
import subprocess
import sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def ind(l):
    return len(l) - len(l.lstrip(' '))


def extent(lines, lo, hi):
    b = ind(lines[lo])
    k = lo + 1
    while k < hi:
        if lines[k].strip() and ind(lines[k]) <= b:
            break
        k += 1
    return k


def members(lines, lo, hi):
    b = ind(lines[lo])
    fields, kids, tag = {}, [], None
    i = lo + 1
    while i < hi:
        l = lines[i]
        if not l.strip():
            i += 1
            continue
        if ind(l) <= b:
            break
        st = l.strip()
        if st.startswith('|'):
            if ':' in st:
                k, v = st[1:].split(':', 1)
                fields[k] = v
            tag = st[1:].split(':')[0]
            i += 1
            continue
        if st.startswith('\\_'):
            e = extent(lines, i, hi)
            kids.append((tag, i, e))
            i = e
            continue
        i += 1
    return fields, kids


def scan(path):
    """{param name: set of shape signatures} for one dumped database."""
    out = subprocess.run([DUMP, path], capture_output=True, text=True,
                         errors='replace')
    lines = out.stdout.split('\n')
    res = {}
    for i, l in enumerate(lines):
        if not l.lstrip().startswith('\\_param_assign:'):
            continue
        e = extent(lines, i, len(lines))
        _, kids = members(lines, i, e)
        lhs = [k for k in kids if k[0] == 'vpiLhs']
        rhs = [k for k in kids if k[0] == 'vpiRhs']
        if not lhs or not rhs:
            continue
        n = lines[lhs[0][1]].strip()
        name = (n[n.find('(') + 1:n.find(')')] if '(' in n else '')
        name = name.split('::')[-1].split('.')[-1]
        rlo, rhi = rhs[0][1], rhs[0][2]
        node = lines[rlo].strip()
        if not node.lstrip('\\_').startswith('operation'):
            continue
        f, k2 = members(lines, rlo, rhi)
        if f.get('vpiOpType') != '75':
            continue
        ops = [c for c in k2 if c[0] in ('vpiOperand',)]
        if not ops:
            continue
        kinds = set()
        for _, clo, chi in ops:
            kinds.add(lines[clo].strip().split(':')[0].lstrip('\\_'))
        nested = kinds == {'operation'}
        leafonly = not (kinds & {'operation', 'tagged_pattern'})
        res.setdefault(name, set()).add((len(ops), nested, leafonly))
    return res


def main():
    hits = []
    for moded in sys.argv[1:]:
        for d in sorted(os.listdir(moded)):
            p = os.path.join(moded, d, 'slang.uhdm')
            if not os.path.isfile(p):
                continue
            row = d.rsplit('-', 1)[0]
            try:
                res = scan(p)
            except Exception as ex:                      # noqa: BLE001
                print('ERR %s %s %s' % (moded, row, ex))
                continue
            for name, sigs in res.items():
                defs = [s for s in sigs if s[1] and s[0] >= 2]
                flat = [s for s in sigs if s[2]]
                if defs and flat:
                    hits.append((os.path.basename(moded), row, name,
                                 defs[0][0], sorted(x[0] for x in flat)))
    for h in sorted(set(map(str, hits))):
        print('PREDICT-MOVE ' + h)
    print('rows=%d' % len(set((h[0], h[1]) for h in hits)))
    for r in sorted(set((h[1]) for h in hits)):
        print('ROW %s' % r)


main()
