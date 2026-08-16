#!/usr/bin/env python3
"""r10uvm74 — PREDICT THE MOVERS, from the PRISTINE ARTIFACTS ALONE.

Run this BEFORE byteverify.sh on the same corpus.  A verifier whose expected
answer is written down only after the measurement is not a control.

THE PREDICTOR IS AN UPPER BOUND ON REACHABILITY, NOT AN IFF -- and this
docstring said "EXACT, NOT HEURISTIC ... a database moves IF AND ONLY IF"
until the VERIFIER ran the same predicate on the PATCHED corpus and it still
flagged 24 prints in `default/Rggen`.  The flagged object is a `ref_obj` whose
decompiled text is a single indexed component (`base[idx]`) and whose
`vpiParent` is a `hier_path`.  That is the object this law CONVERTS -- but the
same object is also built by OTHER builders (`emitMixedHierPath`, the
interface-array path: Rggen's `register_if[6+7*i+6]`), and by this law's own
REFUSAL rule, so it legitimately SURVIVES the patch.  A stated invariant its
own run refutes is the campaign's "cited guard that does not exist" trap in
prose form, so: a pristine database moves ONLY IF it prints at least one, the
count is an upper bound on the size of the change, and an out-of-prediction
mover is the finding this control exists to catch.  Measured envelope: 8
flagged, 7 moved.

THE ONE STATED ERROR DIRECTION.  The predictor sees the OBJECT that changes
KIND.  It cannot see a SECOND-ORDER effect: the new index child is emitted
through `emitExpr`, which registers its symbol with the ref collector, and a
database whose only change was such a registration would move WITHOUT printing
a flagged object.  That would appear as a mover OUTSIDE the prediction, and it
is the reading this control exists to catch — so an out-of-prediction mover is
a FINDING, never a rounding error.

  usage: ct74predict.py <pristine verify_golden workdir> [--jobs N]

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
OBJ = re.compile(r'^(\s*)\\_ref_obj: \(([A-Za-z_$][A-Za-z0-9_$]*\[[^\[\]]*\])\), line:')


def scan(path):
    try:
        p = subprocess.run([DUMP, path], capture_output=True, text=True,
                           errors='replace', timeout=900)
    except Exception as e:
        return (path, -1, str(e))
    if p.returncode != 0 and not p.stdout:
        return (path, -1, 'dump rc=%d' % p.returncode)
    lines = p.stdout.splitlines()
    n = 0
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m:
            continue
        base = len(m.group(1))
        # its vpiParent is printed as the first field block below it
        j = i + 1
        field = None
        while j < len(lines) and j < i + 12:
            s = lines[j]
            st = s.lstrip()
            ind = len(s) - len(st)
            if ind <= base and st.startswith('\\_'):
                break
            if st.startswith('|') and ind == base + 2:
                field = st[1:].split(':')[0]
            elif st.startswith('\\_') and ind == base + 2:
                if field == 'vpiParent' and st.startswith('\\_hier_path:'):
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
        print('PREDICT_MOVE %-58s prints=%d' % (rel, n))
    print('---- PREDICTION: %d databases / %d CAN move, %d flagged PRINTS (the dump prints one object once per print-chain that reaches it), '
          'DUMP_FAIL=%d' % (len(movers), len(dbs), total, len(fails)))
    for p, e in fails:
        print('DUMP_FAIL %s  %s' % (p, e))


main()
