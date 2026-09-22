"""r11u93 SITE CENSUS — name EVERY site BOTH laws reach in a corpus, and
PREDICT the mover set BY NAME before any patched sweep is read.  r11u92's
`cellcen92.py` with this pass's three trace lines; the harness replay (its OWN
`discover_*` / `translate` / `location_args`, so a site cannot be missed
because a driver spelled a flag differently) is unchanged, and so is the FENCED
set, read out of `canaudit.sh`'s own `FENCED=` line rather than spelled here.

    R11U93IFMINT    one row per NON-ANSI INTERFACE PORT reaching the interface
                    net listing, with the body declaration's two facts
                    (`body=` whether one exists, `str=` whether the strength
                    law erased it).  A test with no row cannot move under
                    LAW B.
    R11U93PROGFLAT  one row per declaration a PROGRAM home flattens out of a
                    generate block.  A test with no row cannot move under
                    LAW A's listing face.
    R11U93PROGGEN   one row per PROGRAM home whose generate scopes are
                    dropped.  A test with no row cannot move under LAW A's
                    scope face.

All three traces sit OUTSIDE their gates, so ONE run of ONE binary censuses the
population AND predicts the mover set; run it with `R11U93_OFF=1` in the
environment to prove the prediction is independent of the laws firing.

usage: cellcen93.py <slang-uhdm-repo> <corpus> <binary> <out.tsv>
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


tot = {'arms': 0, 'ifmint': 0, 'ifmintBody': 0, 'progFlat': 0,
       'progGen': 0}
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
                                   env=dict(os.environ, R11U93_NETDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U93'):
                    continue
                hit = True
                f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                if l.startswith('R11U93IFMINT'):
                    tot['ifmint'] += 1
                    movers.setdefault(name, set()).add('LAWB-MINT')
                    if ' body=1' in l:
                        tot['ifmintBody'] += 1
                        movers.setdefault(name, set()).add('LAWB-DUP')
                elif l.startswith('R11U93PROGFLAT'):
                    tot['progFlat'] += 1
                    movers.setdefault(name, set()).add('LAWA-FLAT')
                elif l.startswith('R11U93PROGGEN'):
                    tot['progGen'] += 1
                    movers.setdefault(name, set()).add('LAWA-SCOPE')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
