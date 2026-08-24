#!/usr/bin/env python3
"""r10uvm120 — A-PRIORI MOVER PREDICTOR, read off a PRISTINE dump alone.

§ pkgRetParamSubstIsRhsClone120 can only touch a `return_stmt` that lives in a
PACKAGE view and whose condition is either
  (a) a `ref_obj` whose name is a PARAMETER of the enclosing package — the
      substitution that was missing (and the name-keyed shadow half: a local or
      formal carrying a parameter's name reads the same in the dump), or
  (b) a `constant` already parented at a `param_assign` — the old
      value-re-render, whose FIELDS this law replaces with the Rhs clone, or
      the nested-return over-fold this law now refuses.
Anything else in any other view is out of reach, so a database with no such
cell CANNOT move.  Prints one line per candidate cell and a COUNT line.
MEASUREMENT ONLY; the official uhdm-cmp is the judge.
    pred120.py <dump>
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rets120 import parse, loc


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

    # parameter names per enclosing package object
    parnames = set()
    for o in objs:
        if o['kind'] == 'parameter':
            nm = o['fields'].get('vpiName', [''])[0]
            if nm:
                parnames.add(nm.split('::')[-1])
    n = 0
    for o in objs:
        if o['kind'] != 'return_stmt':
            continue
        if 'Packages' not in view_of(o['line']):
            continue
        for k in o['kids']:
            c = objs[k]
            if c['slot'] != 'vpiCondition':
                continue
            if c['kind'] == 'ref_obj':
                nm = c['fields'].get('vpiName', [''])[0].split('::')[-1]
                if nm in parnames:
                    n += 1
                    print('CAND ref %s %s' % (view_of(o['line']), loc(c)))
            elif c['kind'] == 'constant':
                par = None
                for g in c['kids']:
                    if objs[g]['slot'] == 'vpiParent':
                        par = objs[g]
                        break
                if par is not None and par['kind'] == 'param_assign':
                    n += 1
                    print('CAND const %s %s' % (view_of(o['line']), loc(c)))
    print('CANDCOUNT %d' % n)


main(sys.argv[1])
