"""r11u105 SITE CENSUS (r11u103's cellcen103.py + this pass's three laws) --
name EVERY site the laws reach in a corpus, and PREDICT the mover set BY NAME
before any patched sweep is read.

    R11U105TOPKEY            LAW A enters a TOP namesake at its root (MOVER)
    R11U105PROGKEY road=UNINST|INST   LAW B re-enters a program namesake (MOVER)
    R11U105IFACEKEY road=UNINST|INST  LAW C re-enters an interface namesake (MOVER)
    R11U103NAMESAKE kind=<n>  the SUPERSET of all three laws: every file-scope
                              definition (module 0 / interface 1 / program 2)
                              sharing its bare name with a nested one

The harness replay is r11u101's `cellcen101.py` (itself r11u99's
`cellcen99.py`): the harness's OWN `discover_*` / `translate` /
`location_args`, run with 3 workers.  Only the trace decoding is this pass's:

    R11U101NESTANY   one definition declared inside ANOTHER definition's
                     body, any kind, any depth (r11u101's superset)
    R11U103NAMESAKE  a FILE-SCOPE definition sharing its bare name with a
                     nested one -- LAW A's SUPERSET: a zero here means LAW A
                     cannot fire anywhere in the corpus
    R11U103FILEKEY           LAW A re-enters an instantiated file-scope def (MOVER)
    R11U103FILEKEY-DEFONLY   LAW A offers a definition-only file-scope def (MOVER
                             when admitted)
    R11U103UNELAB road=F|NI|NP          LAW B fills a def-view port phase (MOVER
                                        when the walk never fills it)
    R11U103UNELAB road=*-LIBDECLINE     the library guard keeps the base
    R11U103UNELAB road=*-IFACEDECLINE   the interface-port refusal keeps the base

The trace sits OUTSIDE every gate, so ONE run of ONE binary censuses the
population AND predicts the mover set.  A census ZERO needs a POSITIVE
CONTROL: `--seed <dir>` splices a known-positive source directory into the
test set and it must come back flagged.  THE FENCED TESTS ARE NEVER
DISPATCHED (the FENCED set is read out of canaudit.sh's own line).

usage: cellcen105.py <slang-uhdm-repo> <corpus> <LAW binary> <out.tsv> [--seed DIR]
"""


import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

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

tot = {'topKey': 0, 'progKey': 0, 'ifaceKey': 0, 'arms': 0, 'nestAny': 0, 'namesake': 0, 'fileKey': 0,
       'fileKeyDefOnly': 0, 'unelab': 0, 'libDecline': 0, 'ifaceDecline': 0}
rcs = {}
movers = {}
jobs = []
for name in sorted(tests):
    dirpath, parts = tests[name]
    if name in FENCED:
        continue
    for mode, argv in su_vectors(parts):
        jobs.append((name, mode, dirpath, argv))


def run(job):
    name, mode, dirpath, argv = job
    try:
        p = subprocess.run([BIN] + argv + ['-o', '/dev/null'],
                           cwd=dirpath, capture_output=True, text=True,
                           timeout=300,
                           env=dict(os.environ, R11U101_NETDBG='1',
                                    R11U103_NETDBG='1', R11U105_NETDBG='1'))
        return job, p.returncode, p.stderr
    except subprocess.TimeoutExpired:
        return job, 'TIMEOUT', ''


with open(OUT, 'wt') as f, ThreadPoolExecutor(3) as ex:
    for (name, mode, dirpath, argv), rc, err in ex.map(run, jobs):
        tot['arms'] += 1
        rcs[rc] = rcs.get(rc, 0) + 1
        hit = False
        for l in err.split('\n'):
            if not (l.startswith('R11U103') or l.startswith('R11U105') or
                    l.startswith('R11U101NESTANY')):
                continue
            hit = True
            f.write(f'{name}\t{mode}\trc={rc}\t{l}\n')
            if l.startswith('R11U105TOPKEY'):
                tot['topKey'] += 1
                movers.setdefault(name, set()).add('LAWA-TOPKEY')
            elif l.startswith('R11U105PROGKEY'):
                tot['progKey'] += 1
                movers.setdefault(name, set()).add('LAWB-' + l.split('road=')[1].split()[0])
            elif l.startswith('R11U105IFACEKEY'):
                tot['ifaceKey'] += 1
                movers.setdefault(name, set()).add('LAWC-' + l.split('road=')[1].split()[0])
            elif l.startswith('R11U101NESTANY'):
                tot['nestAny'] += 1
            elif l.startswith('R11U103NAMESAKE'):
                tot['namesake'] += 1
            elif l.startswith('R11U103FILEKEY-DEFONLY'):
                tot['fileKeyDefOnly'] += 1
                movers.setdefault(name, set()).add('LAWA-DEFONLY')
            elif l.startswith('R11U103FILEKEY'):
                tot['fileKey'] += 1
                movers.setdefault(name, set()).add('LAWA-FILEKEY')
            elif 'LIBDECLINE' in l:
                tot['libDecline'] += 1
            elif 'IFACEDECLINE' in l:
                tot['ifaceDecline'] += 1
            elif l.startswith('R11U103UNELAB'):
                tot['unelab'] += 1
                movers.setdefault(name, set()).add('LAWB-' + l.split('road=')[1].split()[0])
        if not hit:
            f.write(f'{name}\t{mode}\trc={rc}\tNO-SITE\n')
    f.write('#TOTALS\t' + '\t'.join(f'{k}={v}' for k, v in tot.items()) + '\n')
    f.write('#RC\t' + '\t'.join(f'rc={k}:{v}' for k, v in sorted(
        rcs.items(), key=lambda x: str(x[0]))) + '\n')
    for t in sorted(movers):
        f.write(f'#PREDICTED-MOVER\t{t}\t{",".join(sorted(movers[t]))}\n')
print(OUT, tot)
print('PREDICTED MOVERS:', {t: sorted(v) for t, v in movers.items()} or 'NONE')
