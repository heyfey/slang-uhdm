#!/usr/bin/env python3
"""r10buvm18repro/predict18.py — PREDICT THE MOVER SET, BY NAME, FROM THE
GOLDEN DATABASES ALONE.  MEASUREMENT ONLY; uhdm-cmp and verify_golden.py are
the judges.

LHS is ALWAYS golden.  § pkgParamBareTdNamedClone18 changes exactly one thing
in our output: a PACKAGE-homed parameter written with the BARE name of a
typedef homed in that same package stops carrying the untyped `int_typespec`
default and starts carrying a NAMED clone of the typedef's typespec with a
`Typedef_alias`.  GOLDEN ALREADY HAS THAT SHAPE wherever the law applies, and
golden is independent of our binaries -- so the set of tests whose GOLDEN
database contains at least one

    view in {DEFPKG, ELABPKG}   and   the actual typespec is
    bit_/int_/byte_typespec     and   it carries `[alias->`
    and its vpiParent is the parameter (a per-declaration CLONE, not a share)

is a SUPERSET of the rows our dumps can move on, computed before the patched
sweep is looked at.  A byte mover outside this set is an OVER-FIRE and has to
be explained, not excused.

usage: predict18.py <sweep-workdir> [census-binary]
       (the workdir is a verify_golden.py --workdir tree; each test dir's
        cmds.txt names the golden cache directory it read)
"""
import os, re, subprocess, sys

WD = sys.argv[1]
CEN = sys.argv[2] if len(sys.argv) > 2 else '/tmp/r10buvm18_cen'

pat = re.compile(r'golden cache hit ([^)\s]+)')
tests = {}                      # test-dir basename -> golden.uhdm path
for mode in sorted(os.listdir(WD)):
    md = os.path.join(WD, mode)
    if not os.path.isdir(md):
        continue
    for t in sorted(os.listdir(md)):
        c = os.path.join(md, t, 'cmds.txt')
        if not os.path.isfile(c):
            continue
        txt = open(c, errors='replace').read()
        m = pat.search(txt)
        g = os.path.join(m.group(1), 'golden.uhdm') if m else None
        if not g:                       # freshly produced golden, not cached
            for sub in ('slpp_all', 'slpp_unit'):
                p = os.path.join(md, t, sub)
                if os.path.isdir(p):
                    for f in sorted(os.listdir(p)):
                        if f.endswith('.uhdm'):
                            g = os.path.join(p, f)
        if g and os.path.isfile(g):
            tests[(mode, t)] = g

seen = {}
hits = []
for (mode, t), g in sorted(tests.items()):
    if g not in seen:
        try:
            out = subprocess.run([CEN, g], capture_output=True, text=True,
                                 timeout=600).stdout
        except Exception:
            out = ''
        rows = []
        for ln in out.splitlines():
            f = ln.split('\t')
            if len(f) < 6:
                continue
            view, val = f[0], f[5]
            if view not in ('DEFPKG', 'ELABPKG'):
                continue
            if '[alias->' not in val or 'apar=parameter' not in val:
                continue
            if not (val.startswith('bit_typespec') or
                    val.startswith('int_typespec') or
                    val.startswith('byte_typespec')):
                continue
            rows.append((f[1], f[2]))
        seen[g] = rows
    if seen[g]:
        hits.append((t.rsplit('-', 1)[0], mode, len(seen[g])))

names = sorted({h[0] for h in hits})
print('PREDICTED-MOVER-TESTS %d' % len(names))
for n in names:
    print('  %s' % n)
print('PREDICTED-CELLS %d over %d (test,mode) pairs' %
      (sum(h[2] for h in hits), len(hits)))
