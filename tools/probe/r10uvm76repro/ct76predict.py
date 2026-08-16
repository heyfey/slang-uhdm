#!/usr/bin/env python3
"""r10uvm76 — PREDICT THE MOVERS, from the PRISTINE ARTIFACTS ALONE.

Run this BEFORE byteverify.sh, on the PRISTINE workdir, so the expected answer
is written down before the measurement.

THE PREDICATE IS AN UPPER BOUND ON REACHABILITY, NOT AN IFF.
§ classEnumConstBindsHoistNet76 can only touch a database that declares a
CLASS-SCOPE ENUM CONSTANT: its one site fires on `SymbolKind::EnumValue` whose
scope chain reaches a `ClassType` before any package / instance body /
compilation unit.  A pristine database with zero class-scope `enum_const`
declarations therefore CANNOT move.  The converse is FALSE, deliberately, and
in three separate ways the artifact cannot show:

  * the reference must be written UNQUALIFIED — a `::`-scoped read
    (`process::KILLED`) names its own scope and golden leaves it bare
    (arm b3_qual; 24 such references in SimpleUVM alone),
  * the reference must sit in an OUT-OF-BODY class method — an in-body one
    resolves at class scope and golden nets nothing (arm b2_inbody), and
  * some module in the design must HOIST that class's package (arm
    v76_nohoist is the negative: the package is compiled but never imported).

A flagged database that does not move is therefore EXPECTED and is reported as
such.  A mover OUTSIDE the prediction is a FINDING, never a rounding error.

  usage: ct76predict.py <pristine verify_golden workdir> [--jobs N]

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
CLS = re.compile(r'^(\s*)\\_class_defn: ')
EC = re.compile(r'^(\s*)\\_enum_const: \(([^)]*)\)')


def scan(path):
    """-> (path, class-scope enum constants, err).  Counted by NAME, once per
    database, so a constant printed in several views is one candidate."""
    try:
        p = subprocess.run([DUMP, path], capture_output=True, text=True,
                           errors='replace', timeout=1800)
    except Exception as e:
        return (path, -1, str(e))
    if p.returncode != 0 and not p.stdout:
        return (path, -1, 'dump rc=%d' % p.returncode)
    lines = p.stdout.splitlines()
    names = set()
    # indentation walk: an enum_const printed strictly inside a class_defn's
    # subtree is class-scope.  Nested class_defns only tighten the window, so
    # tracking the innermost open class is enough.
    open_cls = []           # stack of class_defn indents
    for ln in lines:
        st = ln.lstrip()
        if not st:
            continue
        ind = len(ln) - len(st)
        while open_cls and ind <= open_cls[-1]:
            open_cls.pop()
        m = CLS.match(ln)
        if m:
            open_cls.append(ind)
            continue
        e = EC.match(ln)
        if e and open_cls:
            names.add(e.group(2))
    return (path, len(names), '')


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
    fails, cands, total = [], [], 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for path, n, err in ex.map(scan, dbs):
            if n < 0:
                fails.append((path, err))
                continue
            if n:
                cands.append((os.path.relpath(path, root), n))
                total += n
    cands.sort()
    for rel, n in cands:
        print('PREDICT_MOVE %-58s classEnumConsts=%d' % (rel, n))
    print('---- PREDICTION: %d databases / %d CAN move, %d class-scope enum '
          'constants, DUMP_FAIL=%d' % (len(cands), len(dbs), total, len(fails)))
    for p, e in fails:
        print('DUMP_FAIL %s  %s' % (p, e))


main()
