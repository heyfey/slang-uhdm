#!/usr/bin/env python3
"""r10rgg9/cand9.py -- the PRISTINE-database candidate upper bound.

  usage: cand9.py <verify_golden workdir> <cacensus9 binary>

Reads the BASE (pristine) `slang.uhdm` of every test in a verify_golden
workdir and reports every test whose ELABORATED view carries a cont_assign
whose vpiRhs is a 3-operand `operation` with `vpiOpType 32` (vpiConditionOp)
— the ONLY shape § srlgCondOpInstValueTernFold9 can move.  NO BINARY IS
DISPATCHED: this is the upper bound read off databases the patch never saw,
so the mover set can be named BEFORE the patched sweep runs.

The four SLANG-FENCED tests are skipped BY NAME-HASH and COUNTED, never
spelled.
"""
import hashlib
import os
import re
import subprocess
import sys

# The four fenced names, carried as hashes so this file never spells them.
FENCED_SHA1 = {
    'a3c001f49e48fee0c4d5ca2ef8034722b92ff46f',
    'c33112b1bcdc7cfec4ffddb2efd047fa13406de5',
    '167fe228e325501a5e75c80ec2d1b8c4f71c6f4b',
    '4187155babb2ef13b451994603595c455d85c1be',
}


def fenced(name):
    return hashlib.sha1(name.encode()).hexdigest() in FENCED_SHA1


def main():
    wd, scan = sys.argv[1], sys.argv[2]
    env = dict(os.environ)
    env['LD_LIBRARY_PATH'] = os.path.expanduser('~/.local/lib64') + ':' + \
        os.path.expanduser('~/.local/lib') + ':' + env.get('LD_LIBRARY_PATH', '')
    hits, scanned, skipped, nodb = [], 0, 0, 0
    for mode in sorted(os.listdir(wd)):
        md = os.path.join(wd, mode)
        if not os.path.isdir(md):
            continue
        for d in sorted(os.listdir(md)):
            name = re.sub(r'-[0-9a-f]{8}$', '', d)
            if fenced(name):
                skipped += 1
                continue
            db = os.path.join(md, d, 'slang.uhdm')
            if not os.path.exists(db) or os.path.getsize(db) == 0:
                nodb += 1
                continue
            scanned += 1
            r = subprocess.run([scan, db], capture_output=True, text=True,
                               env=env, timeout=1200)
            n = 0
            for ln in r.stdout.splitlines():
                f = ln.split('\t')
                if len(f) >= 5 and f[0] == 'ELAB' and \
                        f[4].startswith('operation(op=32,n=3)'):
                    n += 1
            if n:
                hits.append((name, mode, n))
    for name, mode, n in hits:
        print('CANDIDATE\t%s\t%s\t%d' % (name, mode, n))
    print('-- scanned=%d candidates=%d fenced-skipped=%d nodb=%d' %
          (scanned, len(hits), skipped, nodb))


if __name__ == '__main__':
    main()
