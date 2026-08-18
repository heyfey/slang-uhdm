#!/usr/bin/env python3
"""r10rgg9/predict9.py -- the MOVER PREDICTION, read off GOLDEN and the
PRISTINE base databases, with NO patched binary involved.

  usage: predict9.py <base verify_golden workdir> <cacensus9 binary>
                     <corpus-label> [<candidate-list-file>]

The optional 4th argument is a `cand9.py` CANDIDATE listing: only the names it
carries are censused, which is sound because a test with NO 3-operand
`operation(op=32)` in its ELABORATED view cannot host this law's fold at all.
The names NOT censused are COUNTED and printed, never silently dropped.

For every test in the workdir it censuses the GOLDEN database (found through
the workdir's OWN cmds.txt, so the wrong golden cannot silently be read) and
the PRISTINE base database, and reports every ELAB cont_assign where

    golden = a LOC-LESS `INT:<v>` vpiSize 64 constant   (the reducer's own
             vpiConditionOp result)
  or golden = a constant while ours is a 3-operand `operation(op=32)`
             (the arm-object install, a_over64 / a_xz)
and ours   = `operation(op=32,n=3)`.

Those rows are exactly what § srlgCondOpInstValueTernFold9 must move, so the
mover set is NAMED here BEFORE the patched sweep is read.

The four SLANG-FENCED tests are skipped BY NAME-HASH and COUNTED.
"""
import hashlib
import os
import re
import subprocess
import sys

FENCED_SHA1 = {
    'a3c001f49e48fee0c4d5ca2ef8034722b92ff46f',
    'c33112b1bcdc7cfec4ffddb2efd047fa13406de5',
    '167fe228e325501a5e75c80ec2d1b8c4f71c6f4b',
    '4187155babb2ef13b451994603595c455d85c1be',
}


def fenced(name):
    return hashlib.sha1(name.encode()).hexdigest() in FENCED_SHA1


def census(scan, db, env):
    r = subprocess.run([scan, db], capture_output=True, text=True, env=env,
                       timeout=3600)
    out = {}
    for ln in r.stdout.splitlines():
        f = ln.split('\t')
        if len(f) >= 5:
            out[(f[0], f[1], f[2], f[3])] = f[4]
    return out


def main():
    wd, scan, label = sys.argv[1], sys.argv[2], sys.argv[3]
    only = None
    if len(sys.argv) > 4:
        only = set()
        for ln in open(sys.argv[4]):
            f = ln.split('\t')
            if len(f) >= 3 and f[0] == 'CANDIDATE':
                only.add(f[1])
    env = dict(os.environ)
    env['LD_LIBRARY_PATH'] = (os.path.expanduser('~/.local/lib64') + ':' +
                              os.path.expanduser('~/.local/lib') + ':' +
                              env.get('LD_LIBRARY_PATH', ''))
    names, rows, scanned, skipped, nogold, notcand = set(), 0, 0, 0, 0, 0
    for mode in sorted(os.listdir(wd)):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            name = re.sub(r'-[0-9a-f]{8}$', '', d)
            if fenced(name):
                skipped += 1
                continue
            if only is not None and name not in only:
                notcand += 1
                continue
            db = os.path.join(md, d, 'slang.uhdm')
            cm = os.path.join(md, d, 'cmds.txt')
            if not os.path.exists(db) or os.path.getsize(db) == 0:
                continue
            g = None
            if os.path.exists(cm):
                m = re.search(r'golden cache hit (/[^)\s]*)', open(cm).read())
                if m:
                    g = os.path.join(m.group(1), 'golden.uhdm')
            if not g or not os.path.exists(g):
                nogold += 1
                continue
            scanned += 1
            gc = census(scan, g, env)
            oc = census(scan, db, env)
            for k, gv in gc.items():
                if k[0] != 'ELAB':
                    continue
                ov = oc.get(k)
                if ov is None or not ov.startswith('operation(op=32,n=3)'):
                    continue
                if not gv.startswith('constant('):
                    continue
                print('PREDICT\t%s\t%s\t%s\t%s\t%s\t%s' %
                      (name, mode, k[1], k[2], gv, ov))
                names.add(name)
                rows += 1
    print('-- corpus=%s scanned=%d PREDICTED-ROWS=%d PREDICTED-NAMES=%d '
          'fenced-skipped=%d no-golden=%d non-candidate-skipped=%d' %
          (label, scanned, rows, len(names), skipped, nogold, notcand))
    print('-- NAMES: ' + ' '.join(sorted(names)))


if __name__ == '__main__':
    main()
