#!/usr/bin/env python3
"""r10uvm120 — A-PRIORI CENSUS of Surelog's return-window parameter
substitution, read straight off a GOLDEN uhdm-dump.

THE SIGNATURE.  `CompileHelper::getValue` / `compileExpression`'s primary
arm substitute a bare parameter read by

    result = clone_tree(param_assign->Rhs());
    result->VpiParent(param_assign);
    fC->populateCoreMembers(<the REFERENCE node>, ..., result);

so the substituted object is the ONLY object in the database that is parented
to a `param_assign` while its own span lies OUTSIDE that param_assign's span.
The param_assign's real Rhs is parented the same way but spans INSIDE it.
That test needs no scope walk and no name matching, so it finds every
substitution in the DB whatever position it sits in.

    cen120.py <dump> [--all]
prints one TSV row per substituted cell:
    <view> <kind> <span> <param_assign span> <decompile> <ancestor chain>
MEASUREMENT ONLY; the official uhdm-cmp is the judge.
"""
import sys, re
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from rets120 import parse, loc, LOC


def span(o):
    m = LOC.search(o['header'])
    return tuple(int(x) for x in m.groups()) if m else None


def inside(a, b):
    """span a lies within span b"""
    if not a or not b:
        return False
    return (a[0], a[1]) >= (b[0], b[1]) and (a[2], a[3]) <= (b[2], b[3])


def main(path):
    objs = parse(path)
    views = []
    with open(path, 'rt', errors='replace') as f:
        for ln, line in enumerate(f):
            if line.startswith('|uhdm'):
                views.append((ln + 1, line.strip().lstrip('|').rstrip(':')))

    def view_of(ln):
        v = 'PRE'
        for s, n in views:
            if s <= ln:
                v = n
        return v

    seen = set()
    for o in objs:
        # the dump prints vpiParent as a child row
        par = None
        for k in o['kids']:
            if objs[k]['slot'] == 'vpiParent':
                par = objs[k]
                break
        if par is None or par['kind'] != 'param_assign':
            continue
        if o['slot'] == 'vpiRhs' or o['slot'] == 'vpiLhs':
            continue
        so, sp = span(o), span(par)
        if inside(so, sp):
            continue
        # ancestor chain in the printed tree
        chain, p = [], o['parent']
        while p is not None and len(chain) < 6:
            q = objs[p]
            nm = q['fields'].get('vpiFullName', q['fields'].get('vpiName', ['']))[0]
            chain.append(q['kind'] + ('(' + nm + ')' if nm else ''))
            p = q['parent']
        f = o['fields']
        row = '\t'.join((view_of(o['line']), o['kind'], loc(o), loc(par),
                         f.get('vpiDecompile', ['-'])[0],
                         f.get('vpiSize', ['-'])[0],
                         f.get('vpiConstType', ['-'])[0],
                         o['slot'] or '-', '<'.join(chain)))
        if row in seen:
            continue
        seen.add(row)
        print(row)


main(sys.argv[1])
