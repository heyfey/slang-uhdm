#!/usr/bin/env python3
"""r11u90 SITE CENSUS — name EVERY site BOTH laws reach in a corpus, with each
gate's answer, and PREDICT the mover set BY NAME before any patched sweep is
read.

It replays the harness's OWN discovery and its OWN slang argument vector (the
same `discover_*` / `translate` / `location_args` code path
`scripts/verify_golden.py` uses, so a site cannot be missed because a driver
spelled a flag differently), runs the PATCHED binary with `R11U90_CELLDBG=1`,
and records, per test x mode, every invocation's rc and:

    R11U90NET   one row per NET reaching a listing site (`site=` names which:
                moddef / modelab / ifdef / ifelab / gen), with `str=` (the
                declaration carries a drive or charge strength), `port=` (the
                u12 boundary) and `drop=` (LAW A's answer).  A test with no
                `drop=1` row cannot move under LAW A's NET face.
    R11U90CELL  one row per NET reaching a net-declaration-assignment CELL
                site, with `str=` and `drop=`.  Same rule.
    R11U90DLY   one row per `cont_assign` delay LAW B respells as a reference,
                with the name it binds.  A test with no row cannot move under
                LAW B.

The trace sits OUTSIDE both gates, so ONE run of ONE binary censuses the whole
population AND predicts the mover set; run it with `R11U90_OFF=1` in the
environment to prove the prediction is independent of the laws firing.

usage: cellcen90.py <slang-uhdm-repo> <corpus> <patched-binary> <out.tsv>
"""
import os
import subprocess
import sys

REPO, CORPUS, BIN, OUT = sys.argv[1:5]
sys.path.insert(0, os.path.join(REPO, 'scripts'))
os.environ.setdefault('SLANG_UHDM', BIN)
import verify_golden as vg          # noqa: E402

vg.SLANG_UHDM = BIN

tests = (vg.discover_surelog(None) if CORPUS == 'surelog'
         else vg.discover_uhdm2rtlil(None))

# The harness's own deferred set, PLUS the four slang-fenced names, which this
# driver must never dispatch.  They are read out of the canary auditor's own
# `FENCED=` line rather than written here, so the auditor stays the one place
# that spells them and `canaudit.sh` keeps passing over this directory.
FENCED = set(getattr(vg, 'DEFERRED_TESTS', set()))
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       'canaudit.sh')) as _f:
    for _l in _f:
        if _l.startswith('FENCED='):
            FENCED |= set(_l.split('=', 1)[1].strip().strip('"').split())
            break


def su_vectors(parts):
    """The harness's own slang argv per mode, minus the -o it appends."""
    out = []
    sources, _ = vg.split_sources(parts)
    loc, _sl_only = vg.location_args(parts)
    out.append(('default',
                [vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) +
                ['--single-unit']))
    su_args, blocking, nodb, nobuiltin = vg.translate(parts)
    if not nodb and not blocking:
        if nobuiltin:
            su_args = su_args + ['--nobuiltin']
        out.append(('testflags', su_args))
    return out


tot = {'arms': 0, 'net': 0, 'netStr': 0, 'netDrop': 0, 'netStrPort': 0,
       'cell': 0, 'cellStr': 0, 'cellDrop': 0, 'dly': 0}
sites = {}
rcs = {}
movers = {}
with open(OUT, 'wt') as f:
    for name in sorted(tests):
        dirpath, parts = tests[name]
        if name in FENCED:
            continue
        for mode, argv in su_vectors(parts):
            try:
                p = subprocess.run([BIN] + argv + ['-o', '/dev/null'],
                                   cwd=dirpath, capture_output=True, text=True,
                                   timeout=180,
                                   env=dict(os.environ, R11U90_CELLDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U90'):
                    continue
                hit = True
                if l.startswith('R11U90NET'):
                    tot['net'] += 1
                    st = ' site=' in l and l.split(' site=')[1].split()[0]
                    sites[st] = sites.get(st, 0) + 1
                    if ' str=1' in l:
                        tot['netStr'] += 1
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                        if ' port=1' in l:
                            tot['netStrPort'] += 1
                    if ' drop=1' in l:
                        tot['netDrop'] += 1
                        movers.setdefault(name, set()).add('LAWA-NET')
                elif l.startswith('R11U90CELL'):
                    tot['cell'] += 1
                    if ' str=1' in l:
                        tot['cellStr'] += 1
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                    if ' drop=1' in l:
                        tot['cellDrop'] += 1
                        movers.setdefault(name, set()).add('LAWA-CELL')
                elif l.startswith('R11U90DLY'):
                    tot['dly'] += 1
                    movers.setdefault(name, set()).add('LAWB')
                    f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#SITES\t' + '\t'.join(f'{k}={v}' for k, v in sorted(
        sites.items(), key=lambda x: str(x[0]))) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('SITES:', sites)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
