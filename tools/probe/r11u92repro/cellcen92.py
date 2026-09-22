"""r11u92 SITE CENSUS — name EVERY site BOTH laws reach in a corpus, with each
gate's answer, and PREDICT the mover set BY NAME before any patched sweep is
read.  r11u90's `cellcen90.py` with this pass's two trace lines; the harness
replay (its OWN `discover_*` / `translate` / `location_args`, so a site cannot
be missed because a driver spelled a flag differently) is unchanged, and so is
the FENCED set, read out of `canaudit.sh`'s own `FENCED=` line rather than
spelled here.

    R11U92PROG  one row per PROGRAM home reaching `emitContAssigns`, with the
                home's full name, the view (`topView=`) and LAW A's answer
                (`drop=`).  A test with no row cannot move under LAW A.
    R11U92NET   one row per NON-ANSI PORT NET reaching the module home's net
                listing, with LAW B's two answers (`ord=` the group, `anch=`
                the span).  A row with `ord=0 anch=0` is a port net the law
                LEAVES ALONE (no strength on its body declaration) and is
                printed too, so the census reads the whole population and not
                just the movers.  A test with no `ord=1`/`anch=1` row cannot
                move under LAW B.

Both traces sit OUTSIDE their gates, so ONE run of ONE binary censuses the
population AND predicts the mover set; run it with `R11U92_OFF=1` in the
environment to prove the prediction is independent of the laws firing.

usage: cellcen92.py <slang-uhdm-repo> <corpus> <patched-binary> <out.tsv>
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


tot = {'arms': 0, 'prog': 0, 'progDrop': 0, 'net': 0, 'netOrd': 0,
       'netAnch': 0}
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
                                   env=dict(os.environ, R11U92_CELLDBG='1',
                                            R11U92_NETDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U92'):
                    continue
                hit = True
                if l.startswith('R11U92PROG'):
                    tot['prog'] += 1
                    f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                    if ' drop=1' in l:
                        tot['progDrop'] += 1
                        movers.setdefault(name, set()).add('LAWA')
                elif l.startswith('R11U92NET'):
                    tot['net'] += 1
                    # Only the MOVERS are written out: the whole traced
                    # population is 125 118 rows across the two corpora, and a
                    # committed artifact that large is noise.  The population
                    # is in the TOTALS line, the movers are named here, and a
                    # test with neither reads NO-SITE.
                    if ' ord=1' in l or 'anch=1' in l:
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                    if ' ord=1' in l:
                        tot['netOrd'] += 1
                        movers.setdefault(name, set()).add('LAWB-ORDER')
                    if ' anch=1' in l:
                        tot['netAnch'] += 1
                        movers.setdefault(name, set()).add('LAWB-ANCHOR')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
