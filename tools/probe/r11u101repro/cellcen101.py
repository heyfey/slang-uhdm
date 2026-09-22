"""r11u101 SITE CENSUS -- name EVERY site this pass's two laws reach in a
corpus, and PREDICT the mover set BY NAME before any patched sweep is read.

The harness replay is r11u99's `cellcen99.py` verbatim (its OWN `discover_*`
/ `translate` / `location_args`, so a site cannot be missed because a driver
spelled a flag differently).  Only the trace decoding is this pass's:

    R11U101NESTANY   one definition declared inside ANOTHER definition's
                     body, any kind, any depth -- the SUPERSET: a zero here
                     means neither law can fire anywhere in the corpus
    R11U101NEST law=A          LAW A mints a def shell for a ported /
                               parameterized nested module (a MOVER)
    R11U101NEST law=A-DECLINE  LAW A's admission rule refuses (no mover)
    R11U101NEST law=B          LAW B re-enters a collision-dropped nested
                               definition under its scoped key (a MOVER)
    ... shadow=1               the entry's bare name also names a FILE-SCOPE
                               definition (R11U101_NESTSHADOW_OFF's face)

The trace sits OUTSIDE every gate, so ONE run of ONE binary censuses the
population AND predicts the mover set.  A census ZERO needs a POSITIVE
CONTROL: `--seed <dir>` splices a known-positive source directory into the
test set and it must come back flagged.  THE FENCED TESTS ARE NEVER
DISPATCHED (the FENCED set is read out of canaudit.sh's own line).

usage: cellcen101.py <slang-uhdm-repo> <corpus> <LAW binary> <out.tsv> [--seed DIR]
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

tot = {'arms': 0, 'nestAny': 0, 'lawA': 0, 'lawAdecline': 0, 'lawB': 0,
       'shadow': 0}
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
                                   env=dict(os.environ, R11U101_NETDBG='1'))
                rc, err = p.returncode, p.stderr
            except subprocess.TimeoutExpired:
                rc, err = 'TIMEOUT', ''
            tot['arms'] += 1
            rcs[rc] = rcs.get(rc, 0) + 1
            hit = False
            for l in err.split('\n'):
                if not l.startswith('R11U101NEST'):
                    continue
                hit = True
                f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
                if l.startswith('R11U101NESTANY'):
                    tot['nestAny'] += 1
                    continue
                if 'shadow=1' in l:
                    tot['shadow'] += 1
                if 'law=A-DECLINE' in l:
                    tot['lawAdecline'] += 1
                elif 'law=A ' in l:
                    tot['lawA'] += 1
                    movers.setdefault(name, set()).add('LAWA-PORTSHELL')
                elif 'law=B ' in l:
                    tot['lawB'] += 1
                    movers.setdefault(name, set()).add('LAWB-KEYSCOPED')
            if not hit:
                f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
