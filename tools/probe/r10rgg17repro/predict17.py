#!/usr/bin/env python3
"""r10rgg17repro/predict17.py — the MOVER PREDICTION, made from PRISTINE
databases only (the BASE sweep's own `slang.uhdm` files), BEFORE the patched
sweep is read.

§ hpConnElemIdxFold17 rewrites exactly ONE object shape: a `hier_path` whose
vpiParent is a `port` and whose FIRST Path_elem is a `ref_obj` whose vpiName
carries a BRACKET — the flat raw-text element the pristine builder mints for a
component select it could not turn into a bit_select.  A database that has no
such object cannot move; a database that has one MAY move (the law additionally
requires the index to read a GENVAR, the connection to be an ELABORATED
gen-scope port actual, and the array slot to resolve).  The predicted set is
therefore a STRICT SUPERSET of the mover set, which is what makes it a fence.

  usage: predict17.py <workdir> <out.txt>
"""
import os, subprocess, sys, re

CEN = '/tmp/r10rgg17_hpcensus'

def scan(db):
    try:
        out = subprocess.run([CEN, db, 'O'], capture_output=True, text=True,
                             timeout=300).stdout
    except Exception as exc:
        return None, str(exc)
    hits = 0
    for ln in out.split('\n'):
        if 'PAR=port:' not in ln or '\t||\t' not in ln:
            continue
        m = re.search(r'\tE0=ref_obj\|R\{([^}]*)\}', ln)
        if m and '[' in m.group(1):
            hits += 1
    return hits, None

def main():
    wd, outp = sys.argv[1], sys.argv[2]
    rows = []
    scanned = 0
    for mode in sorted(os.listdir(wd)):
        mdir = os.path.join(wd, mode)
        if not os.path.isdir(mdir):
            continue
        for d in sorted(os.listdir(mdir)):
            db = os.path.join(mdir, d, 'slang.uhdm')
            if not os.path.isfile(db):
                continue
            scanned += 1
            hits, err = scan(db)
            if err:
                rows.append(('ERROR', mode, d, err))
            elif hits:
                rows.append(('PREDICT', mode, d, str(hits)))
    with open(outp, 'wt') as f:
        f.write('scanned=%d predicted=%d\n' % (scanned,
                                               sum(1 for r in rows if r[0] == 'PREDICT')))
        for r in rows:
            f.write('\t'.join(r) + '\n')
    print('scanned=%d predicted=%d errors=%d' %
          (scanned, sum(1 for r in rows if r[0] == 'PREDICT'),
           sum(1 for r in rows if r[0] == 'ERROR')))

main()
