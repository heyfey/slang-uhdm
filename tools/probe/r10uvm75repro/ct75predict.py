#!/usr/bin/env python3
"""r10uvm75 — PREDICT THE MOVERS, from the PRISTINE ARTIFACTS ALONE.

Run this BEFORE byteverify.sh, on the PRISTINE workdir, so the expected answer
is written down before the measurement.

THE PREDICATE IS AN UPPER BOUND ON REACHABILITY, NOT AN IFF.  § withIterRefBinds
HoistNet75 can only touch a database that contains an ARRAY-METHOD `with`
CLAUSE: both of its sites (the written iterator ARGUMENT, and a bare read of
that iterator inside the with-expression) live under a `method_func_call` that
carries `vpiWith`.  So a pristine database with ZERO such calls CANNOT move.
The converse is FALSE and deliberately so — the law needs two more conditions
that the artifact does not show:

  * the with-clause must sit in an OUT-OF-BODY class method (an in-body one
    resolves at class scope and golden nets nothing — arm b2), and
  * some module in the design must HOIST that class's package (arm v75_nohoist
    is the negative: the package compiled but never imported, and golden nets
    nothing).

A flagged database that does not move is therefore EXPECTED, and is reported as
such.  A mover OUTSIDE the prediction is a FINDING, never a rounding error.

  usage: ct75predict.py <pristine verify_golden workdir> [--jobs N]

GUARDS: a database uhdm-dump cannot read is counted as DUMP_FAIL and printed;
a workdir with zero databases exits 6 rather than printing a clean zero.
"""
import concurrent.futures
import os
import re
import subprocess
import sys

DUMP = os.environ.get('UHDM_DUMP',
                      os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))
MFC = re.compile(r'^(\s*)\\_method_func_call: ')


def scan(path):
    try:
        p = subprocess.run([DUMP, path], capture_output=True, text=True,
                           errors='replace', timeout=1800)
    except Exception as e:
        return (path, -1, str(e))
    if p.returncode != 0 and not p.stdout:
        return (path, -1, 'dump rc=%d' % p.returncode)
    lines = p.stdout.splitlines()
    n = 0
    for i, ln in enumerate(lines):
        m = MFC.match(ln)
        if not m:
            continue
        base = len(m.group(1))
        j = i + 1
        while j < len(lines):
            s = lines[j]
            st = s.lstrip()
            if not st:
                break
            ind = len(s) - len(st)
            if ind <= base:
                break
            if ind == base + 2 and st == '|vpiWith:':
                n += 1
                break
            j += 1
    return (path, n, '')


def main():
    root = sys.argv[1]
    jobs = 4
    if '--jobs' in sys.argv:
        jobs = int(sys.argv[sys.argv.index('--jobs') + 1])
    dbs = []
    for d, _, fs in os.walk(root):
        if 'slang.uhdm' in fs:
            dbs.append(os.path.join(d, 'slang.uhdm'))
    dbs.sort()
    if not dbs:
        print('NO_DATABASES under %s' % root)
        sys.exit(6)
    fails, movers, total = [], [], 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for path, n, err in ex.map(scan, dbs):
            if n < 0:
                fails.append((path, err))
                continue
            if n:
                movers.append((os.path.relpath(path, root), n))
                total += n
    movers.sort()
    for rel, n in movers:
        print('PREDICT_MOVE %-58s withCalls=%d' % (rel, n))
    print('---- PREDICTION: %d databases / %d CAN move, %d with-clause calls, '
          'DUMP_FAIL=%d' % (len(movers), len(dbs), total, len(fails)))
    for p, e in fails:
        print('DUMP_FAIL %s  %s' % (p, e))


main()
