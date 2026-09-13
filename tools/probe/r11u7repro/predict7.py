#!/usr/bin/env python3
"""r11u7 — A-PRIORI mover prediction, from the corpus SOURCES alone.

  predict7.py surelog|u2r [--list]

§ ifacePortViewAggregateFlattens can only rewrite a `param_assign` on an
INTERFACE PORT VIEW whose parameter is a STRUCT and whose declaration default
is a NESTED assignment pattern.  So a test can move only if all three of these
appear somewhere in its sources:

  1. the `interface` keyword          (no interface -> emitInterfaceInstance
                                       is never entered, nothing is queued)
  2. a `'{` assignment pattern        (the queue only takes an op75 Rhs)
  3. a NESTED one -- a second `'{` inside the first, or a `'{` whose value
     names a localparam that is itself declared with a nested `'{`

This is deliberately a SUPERSET: it does not know which views are port views,
nor whether the first DECLARED member is the aggregate one.  Every ACTUAL
mover must fall inside it; every test outside it is asserted immovable.
"""
import os, re, sys, glob

SURELOG = os.path.expanduser('~/git-repos/Surelog')
U2R = os.path.expanduser('~/git-repos/uhdm2rtlil/test')

def sources_surelog():
    tests = {}
    for root in (os.path.join(SURELOG, 'tests'),
                 os.path.join(SURELOG, 'third_party', 'tests')):
        for dp, _d, fs in os.walk(root):
            for fn in fs:
                if fn.endswith('.sl'):
                    tests[fn[:-3]] = dp
    return tests

def sources_u2r():
    return {n: os.path.join(U2R, n) for n in sorted(os.listdir(U2R))
            if os.path.isdir(os.path.join(U2R, n))}

NEST = re.compile(r"'\{[^'}]*'\{")

def text_of(dirpath, cap=4_000_000):
    buf = []
    n = 0
    for dp, _d, fs in os.walk(dirpath):
        for fn in fs:
            if not fn.endswith(('.v', '.sv', '.svh', '.vh')):
                continue
            p = os.path.join(dp, fn)
            try:
                t = open(p, 'rt', errors='replace').read()
            except OSError:
                continue
            n += len(t)
            buf.append(t)
            if n > cap:
                return ''.join(buf)
    return ''.join(buf)

def movable(dirpath):
    t = text_of(dirpath)
    if 'interface' not in t:
        return False
    if "'{" not in t:
        return False
    if NEST.search(t):
        return True
    # a pattern member naming a localparam that is itself a nested pattern
    for m in re.finditer(r"'\{[^}]*\}", t):
        for ident in re.findall(r'\b([A-Za-z_]\w*)\b', m.group(0)):
            d = re.search(r'\b(?:localparam|parameter)\b[^;=]*\b' +
                          re.escape(ident) + r'\s*=\s*(.{0,200})', t, re.S)
            if d and NEST.search(d.group(1)):
                return True
    return False

def main(a):
    which = a[0]
    tests = sources_surelog() if which == 'surelog' else sources_u2r()
    hit = sorted(n for n, d in tests.items() if movable(d))
    print('%s: %d of %d tests can move a priori' % (which, len(hit), len(tests)))
    if '--list' in a:
        for n in hit:
            print(n)

if __name__ == '__main__':
    main(sys.argv[1:])
