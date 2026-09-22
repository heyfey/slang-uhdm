"""r11u95 SITE CENSUS -- name EVERY site this pass's faces reach in a corpus,
and PREDICT the mover set BY NAME before any patched sweep is read.  The
harness replay is r11u93's `cellcen93.py`, unchanged (its OWN `discover_*` /
`translate` / `location_args`, so a site cannot be missed because a driver
spelled a flag differently), with this pass's five trace lines:

    R11U95PROGPROC    one `initial`/`final` a PROGRAM home flattens out of a
                      generate block   (LAW A, process face)
    R11U95PROGTF      one task/function a PROGRAM home flattens out of a
                      generate block   (LAW A, task/func face)
    R11U95PROGCLASS   one class a PROGRAM home flattens out of a generate
                      block            (LAW A, class face)
    R11U95PROGTFINST  one PROGRAM-def subroutine whose `vpiInstance` the
                      elab road now stamps  (§ caProgTaskFuncInstIsElab95 --
                      the WIDEST face: it needs no generate construct)
    R11U95GENZERO     one loop-generate whose entry list was EMPTY and whose
                      written copy is taken from the array's own scope
                      (LAW B)

All five traces sit OUTSIDE their gates, so ONE run of ONE binary censuses the
population AND predicts the mover set; run it with `R11U95_OFF=1` in the
environment to prove the prediction is independent of the laws firing.

usage: cellcen95.py <slang-uhdm-repo> <corpus> <binary> <out.tsv>
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


tot = {'arms': 0, 'progProc': 0, 'progTf': 0, 'progClass': 0,
       'progTfInst': 0, 'genZero': 0}
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
                                   env=dict(os.environ, R11U95_NETDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U95'):
                    continue
                hit = True
                f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                if l.startswith('R11U95PROGPROC'):
                    tot['progProc'] += 1
                    movers.setdefault(name, set()).add('LAWA-PROC')
                elif l.startswith('R11U95PROGTFINST'):
                    tot['progTfInst'] += 1
                    movers.setdefault(name, set()).add('TFINST')
                elif l.startswith('R11U95PROGTF'):
                    tot['progTf'] += 1
                    movers.setdefault(name, set()).add('LAWA-TF')
                elif l.startswith('R11U95PROGCLASS'):
                    tot['progClass'] += 1
                    movers.setdefault(name, set()).add('LAWA-CLASS')
                elif l.startswith('R11U95GENZERO'):
                    tot['genZero'] += 1
                    movers.setdefault(name, set()).add('LAWB-ZERO')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
