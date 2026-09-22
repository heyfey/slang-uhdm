"""r11u99 SITE CENSUS -- name EVERY site this pass's laws reach in a corpus,
and PREDICT the mover set BY NAME before any patched sweep is read.

The harness replay is r11u98's `cellcen98.py` verbatim (which is r11u95's
`cellcen95.py`: its OWN `discover_*` / `translate` / `location_args`, so a
site cannot be missed because a driver spelled a flag differently).  Only the
trace decoding is this pass's:

    R11U99NESTDEF       one module DECLARED INSIDE another module, with its
                        nesting depth -- the SUPERSET predictor for the whole
                        of LAW B (B1 name, B2 no-ref/no-inst, B3 no class
                        home, B4 depth>=2 dropped, B5 no ref actual, B6
                        parent)
    R11U99NESTREF       one def-view `ref_module` LAW B2 declines to write
    R11U99NESTINST      one elaborated `module_inst` LAW B2 declines to write
    R11U99BODYCLASS     one class in a module/interface BODY listing, with
                        `iface=` and `nested=` flags -- `iface=1` is LAW A2's
                        population (a class on an interface that fell through
                        to the module path) and `nested=1` is LAW B3's
    R11U98MODGENCLASS   the LANDED pass-96 trace, kept because its `iface=1`
                        arm is exactly LAW A1's GENERATE face (a class in the
                        generate block of a fallen-through interface); the
                        union of that and `R11U99BODYCLASS iface=1` is a
                        complete predictor for LAW A, whose own site (the
                        design-root walk in UhdmExporter.cpp) reads the same
                        two populations

All traces sit OUTSIDE their gates, so ONE run of ONE binary censuses the
population AND predicts the mover set; run it with `R11U99_OFF=1` in the
environment to prove the prediction is independent of the laws firing.
A census ZERO needs a POSITIVE CONTROL: pass `--seed <dir>` to splice a
known-positive source directory into the test set and assert it is flagged.
THE FENCED TESTS ARE NEVER DISPATCHED (the FENCED set is read out of
canaudit.sh's own line, so this directory never spells one).

usage: cellcen99.py <slang-uhdm-repo> <corpus> <binary> <out.tsv> [--seed DIR]
"""


import os
import subprocess
import sys

ARGV = sys.argv[1:]
SEEDS = []
while '--seed' in ARGV:
    i = ARGV.index('--seed')
    SEEDS.append(ARGV[i + 1])
    del ARGV[i:i + 2]
REPO, CORPUS, BIN, OUT = ARGV[:4]
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


# POSITIVE CONTROL: a seeded directory is dispatched exactly like a corpus
# test and MUST come back flagged, otherwise a census zero means only that the
# driver never ran anything.
for _sd in SEEDS:
    tests['#SEED:' + os.path.basename(_sd.rstrip('/'))] = (
        _sd, ['dut.sv', '-nobuiltin'])

tot = {'arms': 0, 'nestDef': 0, 'nestRef': 0, 'nestInst': 0,
       'bodyClassIface': 0, 'bodyClassNested': 0, 'genClassIface': 0}
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
                                   env=dict(os.environ, R11U99_NETDBG='1',
                                            R11U98_NETDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not (l.startswith('R11U99') or
                        l.startswith('R11U98MODGENCLASS')):
                    continue
                if l.startswith('R11U99BODYCLASS') and \
                        'iface=0' in l and 'nested=0' in l:
                    continue          # an ordinary module home: no law reaches it
                if l.startswith('R11U98MODGENCLASS') and 'iface=0' in l:
                    continue          # pass 96's own population, not this pass's
                hit = True
                f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                if l.startswith('R11U99NESTDEF'):
                    tot['nestDef'] += 1
                    movers.setdefault(name, set()).add('LAWB-NESTDEF')
                elif l.startswith('R11U99NESTREF'):
                    tot['nestRef'] += 1
                    movers.setdefault(name, set()).add('LAWB2-NESTREF')
                elif l.startswith('R11U99NESTINST'):
                    tot['nestInst'] += 1
                    movers.setdefault(name, set()).add('LAWB2-NESTINST')
                elif l.startswith('R11U99BODYCLASS'):
                    if 'iface=1' in l:
                        tot['bodyClassIface'] += 1
                        movers.setdefault(name, set()).add('LAWA2-IFACEBODY')
                    if 'nested=1' in l:
                        tot['bodyClassNested'] += 1
                        movers.setdefault(name, set()).add('LAWB3-NESTCLASS')
                elif l.startswith('R11U98MODGENCLASS'):
                    tot['genClassIface'] += 1
                    movers.setdefault(name, set()).add('LAWA1-IFACEGEN')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
