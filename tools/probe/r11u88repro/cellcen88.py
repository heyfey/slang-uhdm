#!/usr/bin/env python3
"""r11u88 SITE CENSUS — name EVERY site BOTH laws reach in a corpus, with each
gate's answer, and PREDICT the mover set BY NAME before any patched sweep is
read.

It replays the harness's OWN discovery and its OWN slang argument vector (the
same `discover_*` / `translate` / `location_args` code path
`scripts/verify_golden.py` uses, so a site cannot be missed because a driver
spelled a flag differently), runs the PATCHED binary with `R11U88_CELLDBG=1`,
and records, per test x mode, every invocation's rc and:

    R11U88NDA      one row per NET-DECLARATION ASSIGNMENT reaching LAW A's
                   builder in an elaborated interface, with `mint=` (0 when the
                   declaration carries a drive strength) and `dly=`.
                   A test with no row cannot move under LAW A.
    R11U88NDAFOLD  the same cells' LAW C answer (`name=1` = the RHS is a plain
                   name and is substituted + resized).
    R11U88BOTH     one row per `cont_assign` reaching a LISTING site IN EVERY
                   HOME — module def, module elab, interface elab and gen
                   scope — with `str=`, `dly=` and `declined=`.  Only
                   `declined=1` can move a database.
    R11U88MODNDA   the MODULE home's net-decl-assign population, with `str=`:
                   the residue this pass DECLINES TO TOUCH (`q11_ndastrmod`),
                   censused so the next pass knows its size before it decides.

usage: cellcen88.py <slang-uhdm-repo> <corpus> <patched-binary> <out.tsv>
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


KINDS = ('R11U88NDA ', 'R11U88NDAFOLD', 'R11U88BOTH', 'R11U88MODNDA')
tot = {'arms': 0, 'nda': 0, 'ndaMint': 0, 'fold': 0, 'foldName': 0,
       'both': 0, 'bothDeclined': 0, 'modnda': 0, 'modndaStr': 0}
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
                                   env=dict(os.environ, R11U88_CELLDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U88'):
                    continue
                hit = True
                if l.startswith('R11U88NDAFOLD'):
                    tot['fold'] += 1
                    if ' name=1' in l:
                        tot['foldName'] += 1
                        movers.setdefault(name, set()).add('LAWC')
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                elif l.startswith('R11U88NDA '):
                    tot['nda'] += 1
                    if ' mint=1' in l:
                        tot['ndaMint'] += 1
                        movers.setdefault(name, set()).add('LAWA')
                    f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                elif l.startswith('R11U88BOTH'):
                    tot['both'] += 1
                    if l.rstrip().endswith('declined=1'):
                        tot['bothDeclined'] += 1
                        movers.setdefault(name, set()).add('LAWB')
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                elif l.startswith('R11U88MODNDA'):
                    tot['modnda'] += 1
                    if ' str=1' in l:
                        tot['modndaStr'] += 1
                        movers.setdefault(name, set()).add('MODNDA-RESIDUE')
                        f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
