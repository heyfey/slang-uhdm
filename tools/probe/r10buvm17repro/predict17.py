#!/usr/bin/env python3
"""r10buvm17 — PREDICT the byte movers from the PRISTINE OUR-SIDE censuses ALONE.

MEASUREMENT ONLY.  This reads no golden database and no patched database: the
predicate is a statement about OUR emitter's pristine output, so it can be
written before the patched sweep exists.

A database moves iff its pristine census holds a foreach site with

  * view == ELABPKG          -- the elaborated PACKAGE listing, i.e. exactly the
                                package home § foreachElabLoopVarAnyKindBinds17
                                is gated on (a module home reads DEFMOD/TOPMOD,
                                an interface DEFIFACE, a program DEFPROG);
  * a fully RESOLVED vpiLoopVars listing (no `ref_var` entry) -- the
    un-elaborated listing and the class-method clone list `ref_var` and register
    nothing either way;
  * at least one reference to a loop-variable name, and NOT ONE of them bound --
    a site that already binds something is a kind pass 9/19-22 registered
    (int_var, array_var, the associative INDEX, the class-property string), and
    those bind exactly as before.

  usage: predict17.py <censusdir>      (files named <mode>.<test>.p)
"""
import sys
import os
import collections


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    d = sys.argv[1]
    moved, still = [], []
    for fn in sorted(os.listdir(d)):
        if not fn.endswith('.p'):
            continue
        hit = 0
        for ln in open(os.path.join(d, fn)):
            if not ln.startswith('FE '):
                continue
            f = {}
            for tok in ln.rstrip('\n').split(' ')[2:]:
                k, _, v = tok.partition('=')
                if k:
                    f[k] = v
            if f.get('view') != 'ELABPKG':
                continue
            lv = f.get('lv', '<none>')
            if lv == '<none>' or 'ref_var(' in lv:
                continue
            a = f.get('a', '<none>')
            if a == '<none>':
                continue
            acts = [x.partition('->')[2] for x in a.split(';')]
            if all(x == 'BARE' for x in acts):
                hit += 1
        (moved if hit else still).append((fn[:-2], hit))
    print('PREDICTED MOVERS: %d' % len(moved))
    for n, h in moved:
        print('  MOVE %-52s sites=%d' % (n, h))
    print('PREDICTED UNCHANGED: %d' % len(still))
    return 0


sys.exit(main())
