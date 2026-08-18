#!/usr/bin/env python3
"""r10rgg16/predict16.py — PREDICT the byte-mover set BY NAME from the PRISTINE
databases alone, BEFORE the patched sweep is compared.

§ ifacePortViewActualScopeGate16 can only ever REMOVE `vpiParamAssign` entries
from an interface_inst PORT VIEW.  So a database can move only if the pristine
database already contains a port view with a NON-EMPTY param_assign vector:

  TIER-1  PV=1, pa>0 and the owning module_inst's parent is a `gen_scope`
          -> the instantiation sits inside a generate block, so the actual is
             out of scope unless the generate block declares it itself.
             THESE ARE THE EXPECTED MOVERS.
  TIER-2  PV=1, pa>0 with any other parent kind -> a module-scope
          instantiation, which moves only when the actual is not a direct
          member of the module body (an indexed actual; those already carry
          pa=0 through § ifaceArrayElemPortViewNoPa).  Reported so the
          measured mover set can be proved a SUBSET of TIER-1 u TIER-2.

Every database NOT listed here is predicted BYTE-IDENTICAL.

  usage: predict16.py <pristine-workdir-root> <out.txt>

The FOUR slang-fenced tests are never dispatched by this script; it only reads
databases a sweep already wrote.
"""
import os, subprocess, sys, collections

CEN = os.environ.get('PVCENSUS', '/tmp/r10rgg16_pvcensus')


def main(root, out):
    dbs = []
    for d, _, fs in os.walk(root):
        if 'slang.uhdm' in fs:
            dbs.append(os.path.join(d, 'slang.uhdm'))
    dbs.sort()
    t1, t2, bad = [], [], []
    for p in dbs:
        rel = os.path.relpath(p, root)
        try:
            o = subprocess.run([CEN, p], capture_output=True, text=True,
                               errors='replace', timeout=300)
        except subprocess.TimeoutExpired:
            bad.append((rel, 'TIMEOUT')); continue
        if o.returncode != 0:
            bad.append((rel, 'rc=%d' % o.returncode)); continue
        hits1, hits2 = [], []
        for ln in o.stdout.splitlines():
            f = ln.split('\t')
            if len(f) < 10:
                continue
            pv = f[3] == 'PV=1'
            pa = int(f[5].split('=')[1])
            gk = f[9].split('=')[1]
            if pv and pa > 0:
                (hits1 if gk == 'gen_scope' else hits2).append((f[0], f[1], pa, gk))
        if hits1:
            t1.append((rel, hits1))
        elif hits2:
            t2.append((rel, hits2))
    with open(out, 'w') as f:
        f.write('PRISTINE ROOT %s\ndatabases scanned %d\n' % (root, len(dbs)))
        f.write('\nTIER-1 (PREDICTED MOVERS: port view with param_assigns inside a gen scope): %d\n' % len(t1))
        for rel, h in t1:
            f.write('  %s\n' % rel)
            for v, n, pa, gk in h[:8]:
                f.write('      %s %s pa=%d GK=%s\n' % (v, n, pa, gk))
        f.write('\nTIER-2 (possible, module-scope port views with param_assigns): %d\n' % len(t2))
        for rel, h in t2:
            f.write('  %s (%d views)\n' % (rel, len(h)))
        f.write('\nUNREADABLE %d\n' % len(bad))
        for rel, why in bad:
            f.write('  %s %s\n' % (rel, why))
        f.write('\nPREDICTED-IDENTICAL %d\n' % (len(dbs) - len(t1) - len(t2) - len(bad)))
    print('scanned=%d tier1=%d tier2=%d unreadable=%d -> %s'
          % (len(dbs), len(t1), len(t2), len(bad), out))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
